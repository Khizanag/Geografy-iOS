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
            if subscriptionService.isPremium {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    sectionHeader("UNESCO Heritage Sites", premium: true)
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
            } else {
                lockedSection(title: "UNESCO Heritage Sites")
            }
        }
    }

    private var unescoBadge: some View {
        let count = unescoSites.count
        return HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "building.columns.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.indigo)
            Text("\(count) World Heritage Sites")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.indigo)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(DesignSystem.Color.indigo.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - UNESCO Site Row
private struct UNESCOSiteRow: View {
    let site: UNESCOSite

    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                expanded.toggle()
            }
        } label: {
            rowContent
        }
        .buttonStyle(PressButtonStyle())
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
                    .animation(.easeInOut(duration: 0.2), value: expanded)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(siteTypeColor.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: siteTypeIcon)
                .font(DesignSystem.Font.subheadline.weight(.medium))
                .foregroundStyle(siteTypeColor)
        }
    }

    var metaRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(site.type.rawValue)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.medium)
                .foregroundStyle(siteTypeColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(siteTypeColor.opacity(0.12))
                .clipShape(Capsule())
            Text(String(site.yearInscribed))
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var chevron: some View {
        Image(systemName: "chevron.down")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .rotationEffect(.degrees(expanded ? 180 : 0))
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: expanded)
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
