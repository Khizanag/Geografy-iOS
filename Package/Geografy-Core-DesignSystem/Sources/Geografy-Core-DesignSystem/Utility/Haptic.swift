import SwiftUI

/// The Haptics setting in Settings; on unless the person turns it off.
public enum HapticsSetting {
    public static let key = "hapticFeedbackEnabled"
}

public extension View {
    /// The app's only way to play a haptic: the system's feedback on the view whose state changed, played when
    /// `trigger` changes and silenced by the Haptics setting. One haptic per change; a tap that only opens
    /// something plays none.
    func haptic(_ feedback: SensoryFeedback, trigger: some Equatable) -> some View {
        modifier(HapticModifier(trigger: trigger) { _, _ in feedback })
    }

    /// The same, choosing the feedback from the old and new value, or none by returning nil, such as success for a
    /// right answer and error for a wrong one.
    func haptic<Trigger: Equatable>(
        trigger: Trigger,
        _ feedback: @escaping (_ oldValue: Trigger, _ newValue: Trigger) -> SensoryFeedback?
    ) -> some View {
        modifier(HapticModifier(trigger: trigger, feedback: feedback))
    }
}

private struct HapticModifier<Trigger: Equatable>: ViewModifier {
    @AppStorage(HapticsSetting.key) private var isEnabled = true

    let trigger: Trigger
    let feedback: (Trigger, Trigger) -> SensoryFeedback?

    func body(content: Content) -> some View {
        #if os(iOS)
        content.sensoryFeedback(trigger: trigger) { oldValue, newValue in
            isEnabled ? feedback(oldValue, newValue) : nil
        }
        #else
        content
        #endif
    }
}
