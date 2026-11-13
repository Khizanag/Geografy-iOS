import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - UNESCO Section
extension CountryDetailScreen {
    var unescoSites: [UNESCOSite] {
        UNESCOData.data[country.code] ?? []
    }

    @ViewBuilder
    var unescoSection: some View {
        if !unescoSites.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("UNESCO Heritage Sites")
                unescoBadge
                CardView {
                    VStack(spacing: 0) {
                        let sorted = unescoSites.sorted(by: \.yearInscribed)
                        ForEach(Array(sorted.enumerated()), id: \.offset) { index, site in
                            UNESCOSiteRow(site: site)
                            if index < sorted.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
            }
        }
    }

    private var unescoBadge: some View {
        InfoPill(
            "\(unescoSites.count) World Heritage Sites",
            systemImage: "building.columns.fill",
            style: .tinted(DesignSystem.Color.indigo)
        )
    }
}

// MARK: - UNESCO Site Row
private struct UNESCOSiteRow: View {
    let site: UNESCOSite

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75)) {
                expanded.toggle()
            }
        } label: {
            rowContent
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityValue(expanded ? "Expanded" : "Collapsed")
    }
}

// MARK: - Subviews
private extension UNESCOSiteRow {
    var rowContent: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            typeIcon
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(site.name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                metaRow
                Text(site.description)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(expanded ? nil : 2)
                    .multilineTextAlignment(.leading)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: expanded)
            }
            Spacer(minLength: 0)
            chevron
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
    }

    var typeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(siteTypeColor.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: siteTypeIcon)
                .font(DesignSystem.Font.subheadline.weight(.medium))
                .foregroundStyle(siteTypeColor)
        }
        .accessibilityHidden(true)
    }

    var metaRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            InfoPill(site.type.rawValue, style: .tinted(siteTypeColor))
            Text(String(site.yearInscribed))
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var chevron: some View {
        Image(systemName: "chevron.down")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .rotationEffect(.degrees(expanded ? 180 : 0))
            .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75), value: expanded)
            .accessibilityHidden(true)
    }

    var siteTypeIcon: String {
        switch site.type {
        case .cultural: "building.columns.fill"
        case .natural: "leaf.fill"
        case .mixed: "sparkles"
        }
    }

    var siteTypeColor: Color {
        switch site.type {
        case .cultural: DesignSystem.Color.indigo
        case .natural: DesignSystem.Color.success
        case .mixed: DesignSystem.Color.warning
        }
    }
}
