import CoreHaptics
import GameController

@MainActor
final class TVControllerHaptics {
    static let shared = TVControllerHaptics()

    private var engines: [ObjectIdentifier: CHHapticEngine] = [:]

    private init() {}

    func playTap(on controller: GCController? = nil) {
        play(on: controller, events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                ],
                relativeTime: 0
            ),
        ])
    }

    func playCorrect(on controller: GCController? = nil) {
        play(on: controller, events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6),
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                ],
                relativeTime: 0.15
            ),
        ])
    }

    func playWrong(on controller: GCController? = nil) {
        play(on: controller, events: [
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1),
                ],
                relativeTime: 0,
                duration: 0.35
            ),
        ])
    }

    func playTimerWarning(on controller: GCController? = nil) {
        play(on: controller, events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9),
                ],
                relativeTime: 0
            ),
        ])
    }

    func playCelebration(on controller: GCController? = nil) {
        play(on: controller, events: [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7),
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                ],
                relativeTime: 0.15
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                ],
                relativeTime: 0.30
            ),
        ])
    }
}

// MARK: - Engine Management

private extension TVControllerHaptics {
    func play(on specificController: GCController?, events: [CHHapticEvent]) {
        let targets: [GCController]
        if let specificController {
            targets = [specificController]
        } else {
            targets = GCController.controllers().filter { $0.haptics != nil }
        }

        for controller in targets {
            let engine = engine(for: controller)
            guard let engine else { continue }

            do {
                try engine.start()
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {}
        }
    }

    func engine(for controller: GCController) -> CHHapticEngine? {
        let key = ObjectIdentifier(controller)

        if let cached = engines[key] {
            return cached
        }

        let localities: [GCHapticsLocality] = [.handles, .default]
        for locality in localities {
            if let newEngine = controller.haptics?.createEngine(withLocality: locality) {
                newEngine.resetHandler = { [weak self] in
                    try? newEngine.start()
                    self?.engines[key] = newEngine
                }
                newEngine.stoppedHandler = { _ in }
                engines[key] = newEngine
                return newEngine
            }
        }

        return nil
    }
}
