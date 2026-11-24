import SwiftUI

/// The app's one text field for forms: a name, a title, or a note. A glass capsule like the answer field and the
/// system's own search field; a note that runs to several lines grows in a glass panel with the card corner.
///
/// Text-entry modifiers such as `autocorrectionDisabled()` or `submitLabel(_:)` apply to it as to a `TextField`.
public struct FormField: View {
    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    @ScaledMetric(relativeTo: .body) private var minHeight = TextFieldMetrics.minHeight

    private let placeholder: LocalizedStringKey
    @Binding private var text: String
    private let lineLimit: ClosedRange<Int>?
    private let isInvalid: Bool

    // MARK: - Init
    /// - Parameters:
    ///   - lineLimit: Lines the field grows between for longer text such as notes; nil for one line.
    ///   - isInvalid: Rings the field in red, with the reason shown below it by the caller.
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
        if lineLimit == nil {
            styled(field, in: Capsule())
        } else {
            styled(field, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous))
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
                .padding(.vertical, DesignSystem.Spacing.sm)
        } else {
            TextField(placeholder, text: $text)
        }
    }

    func styled(_ field: some View, in shape: some InsettableShape) -> some View {
        field
            .font(DesignSystem.Font.body)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .frame(minHeight: minHeight)
            .glassEffect(.regular.interactive(), in: shape)
            .overlay {
                shape.strokeBorder(borderColor, lineWidth: isInvalid ? 2 : 1)
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

// MARK: - Metrics
/// Sizes every text field shares, so a form's field and a game's answer field stand the same height.
enum TextFieldMetrics {
    static let minHeight: CGFloat = 52
}
