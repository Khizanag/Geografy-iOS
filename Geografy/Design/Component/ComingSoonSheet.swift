import SwiftUI

struct ComingSoonSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: GeoSpacing.lg) {
            Spacer()
            iconView
            titleView
            subtitleView
            Spacer()
            dismissButton
        }
        .padding(GeoSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GeoColors.background)
    }
}

// MARK: - Subviews

private extension ComingSoonSheet {
    var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 60))
            .foregroundStyle(GeoColors.accent.opacity(0.6))
    }

    var titleView: some View {
        Text(title)
            .font(GeoFont.title)
            .foregroundStyle(GeoColors.textPrimary)
    }

    var subtitleView: some View {
        Text("Coming Soon")
            .font(GeoFont.body)
            .foregroundStyle(GeoColors.textSecondary)
    }

    var dismissButton: some View {
        GeoGlassButton("Close", systemImage: "xmark") { dismiss() }
            .padding(.bottom, GeoSpacing.lg)
    }
}
