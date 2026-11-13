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
                // Outside the column's button, so pronouncing doesn't also open the capital sheet.
                .overlay(alignment: .topTrailing) {
                    SpeakerButton(text: country.capital, countryCode: country.code, size: .compact)
                        .padding(.trailing, DesignSystem.Spacing.xs)
                }
            Divider().frame(height: 56)
            areaButton
            Divider().frame(height: 56)
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
                    icon: "star.fill",
                    title: country.allCapitals.count > 1 ? "Capitals" : "Capital",
                    value: capitalInfoValue,
                    supportsMap: false
                )
            )
        } label: {
            factChip(icon: "star.fill", label: capitalLabel, value: capitalNames)
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
    var capitalLabel: String {
        country.allCapitals.count > 1 ? "Capitals" : "Capital"
    }

    var capitalNames: String {
        country.allCapitals.map(\.name).joined(separator: ", ")
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
            // Two lines reserved in every column, so the three stay the same height and stay aligned.
            Text(value)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.xs)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }
}
