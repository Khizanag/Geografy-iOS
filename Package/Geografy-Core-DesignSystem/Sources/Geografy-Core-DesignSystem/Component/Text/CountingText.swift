import SwiftUI

/// A number that counts up or down to its value when it changes inside an animation,
/// like a score ticking up, instead of swapping digits.
///
/// Give it a value of 0 first, then the real one in `withAnimation`; with Reduce Motion, skip the animation.
public struct CountingText: View, Animatable {
    // MARK: - Properties
    private var value: Double
    private let format: (Double) -> String

    nonisolated public var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    // MARK: - Init
    /// - Parameter format: Turns the number, mid-count, into the text shown: "1 234 km", "+812".
    public init(value: Double, format: @escaping (Double) -> String) {
        self.value = value
        self.format = format
    }

    // MARK: - Body
    public var body: some View {
        Text(verbatim: format(value))
            .monospacedDigit()
    }
}
