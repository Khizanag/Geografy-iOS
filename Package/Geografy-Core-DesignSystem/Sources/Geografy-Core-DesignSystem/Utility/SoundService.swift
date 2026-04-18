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
    public init() {
        #if canImport(AVFoundation)
        configureAudioSession()
        #endif
    }

    /// Play a sound effect. Silently no-ops when disabled or when the asset is missing.
    /// Safe to call from any actor-isolated context on the main actor.
    public func play(_ effect: SoundEffect) {
        guard isEnabled else { return }
        #if canImport(AVFoundation)
        guard let player = player(for: effect) else { return }
        player.currentTime = 0
        player.play()
        #endif
    }

    /// Pre-warm players for the most latency-sensitive effects (quiz feedback).
    /// Call once during app bootstrap.
    public func preload() {
        #if canImport(AVFoundation)
        for effect in [SoundEffect.tap, .correct, .wrong, .streakTick] {
            _ = player(for: effect)
        }
        #endif
    }

    #if canImport(AVFoundation)
    private var players: [SoundEffect: AVAudioPlayer] = [:]
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
        guard let url = Bundle.module.url(
            forResource: effect.resourceName,
            withExtension: effect.fileExtension,
            subdirectory: "Sound"
        ) else {
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

    func configureAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            logger.debug("Audio session configuration failed: \(error.localizedDescription, privacy: .public)")
        }
        #endif
    }
    #endif
}
