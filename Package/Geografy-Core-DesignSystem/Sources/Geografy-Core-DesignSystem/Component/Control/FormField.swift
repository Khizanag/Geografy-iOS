import SwiftUI

/// The app's one text field for forms: a name, a title, or a note, on a card-colored field.
///
/// Text-entry modifiers such as `autocorrectionDisabled()` or `submitLabel(_:)` apply to it as to a `TextField`.
public struct FormField: View {
    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    private let placeholder: LocalizedStringKey
    @Binding private var text: String
    private let lineLimit: ClosedRange<Int>?
    private let isInvalid: Bool

    private static let shape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)

    // MARK: - Init
    /// - Parameters:
    ///   - lineLimit: Lines the field grows between for longer text such as notes; nil for one line.
    ///   - isInvalid: Outlines the field in red, with the reason shown below it by the caller.
    public init(
        _ placeholder: LocalizedStringKey,
        text: Binding<String>,
        lineLimit: ClosedRange<Int>? = nil,
        isInvalid: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.lineLimit = lineLimit
        self.isInvalid = isInvalid
    }

    // MARK: - Body
    public var body: some View {
        field
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(DesignSystem.Spacing.sm)
            .background(DesignSystem.Color.cardBackground, in: Self.shape)
            .overlay {
                Self.shape.strokeBorder(borderColor, lineWidth: 1)
            }
    }
}

// MARK: - Subviews
private extension FormField {
    @ViewBuilder
    var field: some View {
        if let lineLimit {
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(lineLimit)
        } else {
            TextField(placeholder, text: $text)
        }
    }

    var borderColor: Color {
        if isInvalid {
            DesignSystem.Color.error
        } else if colorSchemeContrast == .increased {
            DesignSystem.Color.dividerSubtle
        } else {
            .clear
        }
    }
}
