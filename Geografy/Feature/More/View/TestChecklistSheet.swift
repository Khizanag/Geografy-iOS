import SwiftUI

struct TestChecklistSheet: View {
    let title: String
    let checklist: TestChecklist?

    @State private var checked: Set<Int> = []

    var body: some View {
        NavigationStack {
            Group {
                if let checklist {
                    checklistContent(checklist)
                } else {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No Checklist",
                        subtitle: "No test items defined for this feature yet."
                    )
                }
            }
            .background(DesignSystem.Color.background)
            .navigationTitle("Test: \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
        }
    }
}

// MARK: - Content

private extension TestChecklistSheet {
    func checklistContent(_ checklist: TestChecklist) -> some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(Array(checklist.items.enumerated()), id: \.offset) { index, item in
                    checklistRow(index: index, item: item)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
    }

    func checklistRow(index: Int, item: String) -> some View {
        let isChecked = checked.contains(index)
        return Button {
            if isChecked {
                checked.remove(index)
            } else {
                checked.insert(index)
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(isChecked ? DesignSystem.Color.success : DesignSystem.Color.textTertiary)
                Text(item)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(
                        isChecked ? DesignSystem.Color.textSecondary : DesignSystem.Color.textPrimary
                    )
                    .strikethrough(isChecked)
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
