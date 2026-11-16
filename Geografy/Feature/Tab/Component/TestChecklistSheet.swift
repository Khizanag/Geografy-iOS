import Geografy_Core_DesignSystem
import SwiftUI

/// What to try on one hub screen, in Testing Mode: the screen in its own color, how many checks pass, each check,
/// and a way into the screen. Checks stay ticked between visits until they're cleared.
struct TestChecklistSheet: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var checked: Set<Int> = []

    let item: HubItem
    let checklist: TestChecklist?
    let onOpen: () -> Void

    // MARK: - Body
    var body: some View {
        Group {
            if let checklist {
                checklistForm(checklist)
            } else {
                ContentUnavailableView(
                    "No Checklist",
                    systemImage: "checklist",
                    description: Text("This screen has no checks yet.")
                )
            }
        }
        .navigationTitle("Test Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Uncheck All", systemImage: "arrow.counterclockwise") { update([]) }
                    .disabled(checked.isEmpty)
            }
        }
        .task { checked = Set(UserDefaults.standard.array(forKey: storageKey) as? [Int] ?? []) }
    }
}

// MARK: - Subviews
private extension TestChecklistSheet {
    func checklistForm(_ checklist: TestChecklist) -> some View {
        Form {
            Section {
                header(total: checklist.items.count)
            }
            Section("Checks") {
                ForEach(Array(checklist.items.enumerated()), id: \.offset) { index, text in
                    checkRow(index: index, text: text)
                }
            }
        }
    }

    func header(total: Int) -> some View {
        let passed = checked.count
        let isComplete = passed == total
        return VStack(spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                IconBadge(item.icon, color: item.color, size: .medium)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(item.label)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(isComplete ? "All checks pass" : "\(passed) of \(total) checked")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(isComplete ? DesignSystem.Color.success : DesignSystem.Color.textSecondary)
                        .contentTransition(.numericText())
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: DesignSystem.Spacing.xs)
                openButton
            }
            ProgressView(value: Double(passed), total: Double(max(total, 1)))
                .tint(isComplete ? DesignSystem.Color.success : DesignSystem.Color.iconPrimary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }

    func checkRow(index: Int, text: String) -> some View {
        let isChecked = checked.contains(index)
        return Button {
            update(checked.symmetricDifference([index]))
        } label: {
            Label {
                Text(text)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            } icon: {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(DesignSystem.Font.title3)
                    .foregroundStyle(isChecked ? DesignSystem.Color.success : DesignSystem.Color.textTertiary)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }

    /// A glass style, so only the button opens the screen rather than the whole header row.
    var openButton: some View {
        Button("Open", systemImage: "arrow.up.forward", action: onOpen)
            .buttonStyle(.glass)
            .accessibilityLabel("Open \(item.label)")
    }
}

// MARK: - Helpers
private extension TestChecklistSheet {
    var storageKey: String { "testChecklist.\(item.testKey)" }

    func update(_ newValue: Set<Int>) {
        withAnimation(reduceMotion ? nil : .snappy) {
            checked = newValue
        }
        UserDefaults.standard.set(Array(newValue), forKey: storageKey)
    }
}
