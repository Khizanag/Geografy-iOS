#if canImport(AVFoundation)
import AVFoundation
#endif
import Foundation
import Observation
import os

/// Catalog of curated sound effects used throughout the app.
/// Filenames resolve against `Bundle.module/Resources/Sound/`. Missing assets
/// are no-ops so the build never fails if audio hasn't been sourced yet.
public enum SoundEffect: String, CaseIterable, Sendable {
    case tap
    case correct
    case wrong
    case unlock
    case levelUp = "level-up"
    case streakTick = "streak-tick"
    case sessionComplete = "session-complete"

    public var resourceName: String { rawValue }
    public var fileExtension: String { "caf" }
}

@Observable
@MainActor
public final class SoundService {
    /// Shared instance. SoundService caches AVAudioPlayer instances per effect,
    /// so a single shared player is both thread-correct (MainActor-isolated)
    /// and avoids redundant allocation on every screen.
    public static let shared = SoundService()

    public init() {}

    /// Play a sound effect. Silently no-ops when disabled or when the asset is missing.
    /// Safe to call from any actor-isolated context on the main actor.
    public func play(_ effect: SoundEffect) {
        guard isEnabled, hasSounds else { return }
        #if canImport(AVFoundation)
        guard let player = player(for: effect) else { return }
        player.currentTime = 0
        player.play()
        #endif
    }

    /// Pre-warm players for the most latency-sensitive effects (quiz feedback).
    /// Call once during app bootstrap.
    public func preload() {
        guard hasSounds else { return }
        #if canImport(AVFoundation)
        for effect in [SoundEffect.tap, .correct, .wrong, .streakTick] {
            _ = player(for: effect)
        }
        #endif
    }

    /// Whether the app ships any sound files; with none, no audio is set up at all.
    @ObservationIgnored private lazy var hasSounds = SoundEffect.allCases.contains { Self.url(for: $0) != nil }

    #if canImport(AVFoundation)
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private var isSessionConfigured = false
    #endif
    private let logger = Logger(subsystem: "com.khizanag.geografy.designsystem", category: "sound")
}

// MARK: - Helpers
private extension SoundService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "soundEffectsEnabled") as? Bool ?? true
    }

    #if canImport(AVFoundation)
    func player(for effect: SoundEffect) -> AVAudioPlayer? {
        if let cached = players[effect] { return cached }
        configureAudioSessionOnce()
        guard let url = Self.url(for: effect) else {
            logger.debug("Missing sound asset: \(effect.resourceName, privacy: .public)")
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[effect] = player
            return player
        } catch {
            let name = effect.resourceName
            let reason = error.localizedDescription
            logger.error("Failed to load sound \(name, privacy: .public): \(reason, privacy: .public)")
            return nil
        }
    }

    /// Activating the session can take a moment, so it happens off the main thread, once, before the first
    /// sound is loaded.
    func configureAudioSessionOnce() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true
        #if os(iOS)
        let logger = logger
        Task.detached(priority: .utility) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
                try session.setActive(true, options: [])
            } catch {
                logger.debug("Audio session configuration failed: \(error.localizedDescription, privacy: .public)")
            }
        }
        #endif
    }
    #endif

    nonisolated static func url(for effect: SoundEffect) -> URL? {
        Bundle.module.url(forResource: effect.resourceName, withExtension: effect.fileExtension, subdirectory: "Sound")
    }
}
