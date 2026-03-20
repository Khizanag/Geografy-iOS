import SwiftUI

struct ComingSoonSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        GeoCloseButton()
                    }
                }
        }
    }
}

// MARK: - Subviews

private extension ComingSoonSheet {
    var content: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()
            iconView
            subtitleView
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeoColors.background)
    }

    var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 60))
            .foregroundStyle(GeoColors.accent.opacity(0.6))
    }

    var subtitleView: some View {
        Text("Coming Soon")
            .font(GeoFont.body)
            .foregroundStyle(GeoColors.textSecondary)
    }
}
