import Geografy_Core_Common
import SwiftUI

/// One setting in an options card: a title over a native segmented control, with an optional note below.
/// Long labels or accessibility text sizes get a menu instead, so no segment is ever truncated.
public struct OptionPickerRow<Option: Hashable & Identifiable>: View {
    // MARK: - Style
    public enum Style {
        case segmented
        case menu
    }

    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @Binding private var selection: Option
    private let title: String
    private let options: [Option]
    private let style: Style
    private let note: String?
    private let label: (Option) -> String

    // MARK: - Init
    public init(
        _ title: String,
        selection: Binding<Option>,
        options: [Option],
        style: Style = .segmented,
        note: String? = nil,
        label: @escaping (Option) -> String
    ) {
        self.title = title
        _selection = selection
        self.options = options
        self.style = style
        self.note = note
        self.label = label
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if usesMenu {
                menuRow
            } else {
                titleText
                picker.pickerStyle(.segmented)
            }
            if let note {
                Text(note)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        #if !os(tvOS)
        .onChange(of: selection) { hapticsService.selection() }
        #endif
    }
}

// MARK: - Subviews
private extension OptionPickerRow {
    var titleText: some View {
        Text(title)
            .font(DesignSystem.Font.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var picker: some View {
        Picker(title, selection: $selection) {
            ForEach(options) { option in
                Text(label(option)).tag(option)
            }
        }
    }

    var menuRow: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.xxs))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return layout {
            titleText
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: DesignSystem.Spacing.xs)
            }
            picker
                .pickerStyle(.menu)
                .labelsHidden()
                .tint(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Helpers
private extension OptionPickerRow {
    var usesMenu: Bool {
        style == .menu || dynamicTypeSize.isAccessibilitySize
    }
}
