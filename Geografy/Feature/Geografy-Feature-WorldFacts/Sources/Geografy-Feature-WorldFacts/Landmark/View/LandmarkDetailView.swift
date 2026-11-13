import Geografy_Core_DesignSystem
import SwiftUI

struct LandmarkDetailView: View {
    // MARK: - Properties
    let landmark: Landmark

    private var accentSwiftUIColor: Color {
        Color(hex: landmark.accentColor)
    }

    // MARK: - Body
    var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle(landmark.name)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}

// MARK: - Subviews
private extension LandmarkDetailView {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                heroSection
                metaSection
                descriptionSection
                funFactSection
            }
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
    }

    var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [accentSwiftUIColor.opacity(0.6), accentSwiftUIColor.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: landmark.symbolName)
                    .font(DesignSystem.Font.displayLarge)
                    .foregroundStyle(accentSwiftUIColor)
                    .geoShadow(.elevated)
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: landmark.countryCode, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    Text(landmark.city)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.md)
    }

    var metaSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            categoryBadge
            if landmark.isUNESCO {
                unescooBadge
            }
            if let yearBuilt = landmark.yearBuilt {
                yearBadge(yearBuilt)
            }
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var categoryBadge: some View {
        InfoPill(
            landmark.category.displayName,
            systemImage: landmark.category.icon,
            style: .tinted(accentSwiftUIColor)
        )
    }

    var unescooBadge: some View {
        InfoPill("UNESCO", systemImage: "checkmark.seal.fill", style: .tinted(DesignSystem.Color.blue))
    }

    func yearBadge(_ year: Int) -> some View {
        let displayYear = year < 0 ? "\(String(abs(year))) BC" : "\(String(year)) AD"
        return InfoPill(displayYear)
    }

    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "About", icon: "info.circle.fill")
            CardView {
                Text(landmark.description)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(DesignSystem.Spacing.md)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var funFactSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Fun Fact", icon: "lightbulb.fill")
            CardView {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "lightbulb.fill")
                        .font(DesignSystem.Font.iconDefault)
                        .foregroundStyle(DesignSystem.Color.warning)
                        .padding(.top, 2)
                    Text(landmark.funFact)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}
