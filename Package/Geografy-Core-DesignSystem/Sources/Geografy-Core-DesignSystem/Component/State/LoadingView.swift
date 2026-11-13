import SwiftUI

/// The app's one loading state: a spinner, with an optional line saying what's loading.
public struct LoadingView: View {
    // MARK: - Properties
    private let message: String?

    // MARK: - Init
    public init(_ message: String? = nil) {
        self.message = message
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ProgressView()
                .controlSize(.large)
            if let message {
                Text(message)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message ?? "Loading")
    }
}
