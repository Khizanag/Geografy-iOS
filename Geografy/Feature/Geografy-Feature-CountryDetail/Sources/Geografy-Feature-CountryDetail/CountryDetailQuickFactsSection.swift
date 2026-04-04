import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

// MARK: - Quick Facts
extension CountryDetailScreen {
    var quickFactsCard: some View {
        CardView {
            quickFactsRow
        }
    }

    var quickFactsRow: some View {
        HStack(spacing: 0) {
            capitalButton
            Divider().frame(height: 44)
            areaButton
            Divider().frame(height: 44)
            continentButton
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Buttons
private extension CountryDetailScreen {
    var capitalButton: some View {
        Button {
            activeSheet = .info(
                InfoItem(
                    icon: "mappin.and.ellipse",
                    title: country.allCapitals.count > 1 ? "Capitals" : "Capital",
                    value: capitalInfoValue,
                    supportsMap: false
                )
            )
        } label: {
            capitalChip
        }
        .buttonStyle(PressButtonStyle())
    }

    var areaButton: some View {
        Button {
            activeSheet = .info(
                InfoItem(
                    icon: "map.fill",
                    title: "Area",
                    value: country.area.formatArea(),
                    supportsMap: false
                )
            )
        } label: {
            factChip(icon: "map", label: "Area", value: country.area.formatArea())
        }
        .buttonStyle(PressButtonStyle())
    }

    var continentButton: some View {
        Button {
            activeSheet = .info(
                InfoItem(
                    icon: "globe.americas.fill",
                    title: "Continent",
                    value: country.continent.displayName,
                    supportsMap: true,
                    mapButtonTitle: "Open \(country.continent.displayName) Map"
                )
            )
        } label: {
            factChip(icon: "globe", label: "Continent", value: country.continent.displayName)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Chips
private extension CountryDetailScreen {
    var capitalChip: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "mappin")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(
                country.allCapitals.count > 1
                    ? "Capitals (\(country.allCapitals.count))"
                    : "Capital"
            )
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            if country.allCapitals.count > 1 {
                multipleCapitalsView
            } else {
                singleCapitalView
            }
        }
        .frame(maxWidth: .infinity)
    }

    var multipleCapitalsView: some View {
        VStack(spacing: 2) {
            ForEach(country.allCapitals, id: \.name) { capital in
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    Text(capital.name)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    #if !os(tvOS)
                    SpeakerButton(text: capital.name, countryCode: country.code)
                        .scaleEffect(0.7)
                    #endif
                }
            }
        }
    }

    var singleCapitalView: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(country.capital)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            #if !os(tvOS)
            SpeakerButton(text: country.capital, countryCode: country.code)
                .scaleEffect(0.7)
            #endif
        }
    }

    func factChip(icon: String, label: String, value: String) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(value)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
