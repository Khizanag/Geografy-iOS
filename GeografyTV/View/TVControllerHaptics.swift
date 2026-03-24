import CoreHaptics
import GameController

enum TVControllerHaptics {
    static func playTap(on controller: GCController? = nil) {
        playPattern(on: controller) {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                ],
                relativeTime: 0
            )
        }
    }

    static func playCorrect(on controller: GCController? = nil) {
        playPattern(on: controller) {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6),
                ],
                relativeTime: 0
            )
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                ],
                relativeTime: 0.12
            )
        }
    }

    static func playWrong(on controller: GCController? = nil) {
        playPattern(on: controller) {
            CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: 0,
                duration: 0.3
            )
        }
    }

    static func playTimerWarning(on controller: GCController? = nil) {
        playPattern(on: controller) {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9),
                ],
                relativeTime: 0
            )
        }
    }

    static func playCelebration(on controller: GCController? = nil) {
        playPattern(on: controller) {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7),
                ],
                relativeTime: 0
            )
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                ],
                relativeTime: 0.15
            )
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                ],
                relativeTime: 0.30
            )
        }
    }
}

// MARK: - Engine

private extension TVControllerHaptics {
    @resultBuilder
    struct HapticEventBuilder {
        static func buildBlock(_ events: CHHapticEvent...) -> [CHHapticEvent] { events }
    }

    static func playPattern(
        on specificController: GCController?,
        @HapticEventBuilder events: () -> [CHHapticEvent]
    ) {
        let controllers: [GCController]
        if let specificController {
            controllers = [specificController]
        } else {
            controllers = GCController.controllers().filter { $0.haptics != nil }
        }

        let hapticEvents = events()

        for controller in controllers {
            guard let engine = controller.haptics?.createEngine(withLocality: .default) else { continue }

            do {
                let pattern = try CHHapticPattern(events: hapticEvents, parameters: [])
                try engine.start()
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: CHHapticTimeImmediate)
            } catch {}
        }
    }
}
