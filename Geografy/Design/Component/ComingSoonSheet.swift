import SwiftUI

struct ComingSoonSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack {
                ComingSoonView(icon: icon)

                closeFooter
            }
            .background(DesignSystem.Color.background)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    GeoCircleCloseButton()
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ComingSoonSheet {
    var closeFooter: some View {
        Button { dismiss() } label: {
            Text("Close")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.lg)
    }
}
