import SwiftUI

struct CultureDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let profile: CultureProfile

    private var countryName: String {
        Locale.current.localizedString(forRegionCode: profile.countryCode) ?? profile.countryCode
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerSection
                famousForSection
                detailCardsSection
                funFactSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle(countryName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CircleCloseButton { dismiss() }
            }
        }
    }
}

// MARK: - Subviews

private extension CultureDetailView {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: profile.countryCode, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                .shadow(color: DesignSystem.Color.textPrimary.opacity(0.15), radius: 8, x: 0, y: 4)
            Text(countryName)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(profile.greeting)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
        }
        .padding(.top, DesignSystem.Spacing.md)
    }

    var famousForSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Famous For", icon: "star.fill")
            famousForTags
        }
    }

    var famousForTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(profile.famousFor, id: \.self) { item in
                    Text(item)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .background(DesignSystem.Color.accent, in: Capsule())
                }
            }
        }
    }

    var detailCardsSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            cultureInfoRow(
                icon: "fork.knife",
                label: "National Dish",
                value: profile.nationalDish
            )
            cultureInfoRow(
                icon: "music.note",
                label: "National Instrument",
                value: profile.nationalInstrument
            )
            cultureInfoRow(
                icon: "calendar",
                label: "National Holiday",
                value: "\(profile.nationalHoliday) — \(profile.nationalHolidayDate)"
            )
            cultureInfoRow(
                icon: "bubble.left.fill",
                label: "Greeting",
                value: profile.greeting
            )
        }
    }

    func cultureInfoRow(icon: String, label: String, value: String) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.12))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(value)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var funFactSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Did You Know?", icon: "lightbulb.fill")
            CardView {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DesignSystem.Color.warning)
                        .padding(.top, 2)
                    Text(profile.funCultureFact)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }
}
