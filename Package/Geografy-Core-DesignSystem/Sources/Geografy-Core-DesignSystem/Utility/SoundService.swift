import AVFoundation
import Foundation
import Observation
import os

/// The app's sound effects, one per game moment. Taps and selections stay silent; haptics cover them.
public enum SoundEffect: String, CaseIterable, Sendable {
    /// A right answer, or a found word or country.
    case correct
    /// A wrong answer.
    case wrong
    /// A finished game.
    case complete
    /// A new best, a level up, or an unlocked achievement.
    case celebrate
}

/// Plays sound effects under the "Sound effects" setting. The audio session is ambient, so the sounds follow the
/// silent switch and mix with whatever else is playing.
@Observable
@MainActor
public final class SoundService {
    public static let enabledKey = "soundEffectsEnabled"

    @ObservationIgnored private var players: [SoundEffect: AVAudioPlayer] = [:]
    @ObservationIgnored private var isSessionConfigured = false
    private let logger = Logger(subsystem: "com.khizanag.geografy.designsystem", category: "sound")

    public init() {}

    /// Plays one sound at a time: a new one cuts off the one still ringing, so a result and an achievement that
    /// arrive together don't blur into each other.
    public func play(_ effect: SoundEffect) {
        guard isEnabled, let player = player(for: effect) else { return }
        for (other, playing) in players where other != effect && playing.isPlaying {
            playing.stop()
        }
        player.currentTime = 0
        player.play()
    }

    nonisolated static func url(for effect: SoundEffect) -> URL? {
        Bundle.module.url(forResource: effect.rawValue, withExtension: "caf")
    }
}

// MARK: - Helpers
private extension SoundService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
    }

    func player(for effect: SoundEffect) -> AVAudioPlayer? {
        if let player = players[effect] { return player }
        configureSessionOnce()
        guard let url = Self.url(for: effect) else {
            logger.error("Missing sound \(effect.rawValue, privacy: .public)")
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[effect] = player
            return player
        } catch {
            logger.error("Can't load sound \(effect.rawValue, privacy: .public): \(error.localizedDescription)")
            return nil
        }
    }

    /// Activating the session can block for a moment, so it runs off the main thread, once.
    func configureSessionOnce() {
        guard !isSessionConfigured else { return }
        isSessionConfigured = true
        #if os(iOS)
        let logger = logger
        Task.detached(priority: .utility) {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.ambient)
                try session.setActive(true)
            } catch {
                logger.error("Audio session failed: \(error.localizedDescription)")
            }
        }
        #endif
    }
}
