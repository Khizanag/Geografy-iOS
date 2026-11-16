import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Travel Essentials
/// Practical, traveller-focused facts that appear on every country detail
/// screen: timezone, dialing code, demonym, driving side, internet TLD.
/// Countries without curated data fall back to "Not available" so the layout
/// never collapses.
extension CountryDetailScreen {
    @ViewBuilder
    var travelEssentialsSection: some View {
        let essentials = CountryTravelData.essentials(for: country.code)
        let timeZoneDisplay = CountryTravelData.timeZoneOffsetDisplay(for: country.code)

        if essentials != nil || timeZoneDisplay != nil {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Travel Essentials")
                CardView {
                    travelEssentialsList(essentials: essentials, timeZoneDisplay: timeZoneDisplay)
                        .padding(DesignSystem.Spacing.sm)
                }
            }
        }
    }
}

// MARK: - Essential rows
private struct TravelEssential: Identifiable {
    let icon: String
    let label: String
    let value: String
    var accessibility: String?

    var id: String { label }
}

private extension CountryDetailScreen {
    func travelEssentialsList(
        essentials: CountryTravelData.Essentials?,
        timeZoneDisplay: String?
    ) -> some View {
        let rows = travelEssentials(essentials: essentials, timeZoneDisplay: timeZoneDisplay)
        return VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(rows) { row in
                travelEssentialRow(
                    icon: row.icon,
                    label: row.label,
                    value: row.value,
                    accessibility: row.accessibility
                )
                if row.id != rows.last?.id {
                    Divider()
                }
            }
        }
    }

    func travelEssentials(
        essentials: CountryTravelData.Essentials?,
        timeZoneDisplay: String?
    ) -> [TravelEssential] {
        var rows: [TravelEssential] = []
        if let timeZoneDisplay {
            rows.append(
                TravelEssential(
                    icon: "clock",
                    label: "Timezone",
                    value: timeZoneDisplay,
                    accessibility: "Timezone \(accessibleUTC(timeZoneDisplay))"
                )
            )
        }
        if let code = essentials?.callingCode {
            rows.append(
                TravelEssential(
                    icon: "phone.fill",
                    label: "Dialing code",
                    value: code,
                    accessibility: "Dialing code \(code)"
                )
            )
        }
        if let demonym = essentials?.demonym {
            rows.append(TravelEssential(icon: "person.2.fill", label: "Demonym", value: demonym))
        }
        if let side = essentials?.drivingSide {
            let value = side == .left ? "Left" : "Right"
            rows.append(TravelEssential(icon: "steeringwheel", label: "Driving side", value: value))
        }
        if let tld = essentials?.internetTLD {
            rows.append(TravelEssential(icon: "globe", label: "Internet TLD", value: tld))
        }
        return rows
    }

    func travelEssentialRow(
        icon: String,
        label: String,
        value: String,
        accessibility: String? = nil
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: DesignSystem.Size.Icon.xl)
            Text(label)
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer(minLength: 0)
            Text(value)
                .font(DesignSystem.Font.callout.weight(.semibold))
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibility ?? "\(label): \(value)")
    }

    /// Expand "UTC+03:00" → "UTC plus 3 hours 0 minutes" for VoiceOver clarity.
    func accessibleUTC(_ display: String) -> String {
        display
            .replacingOccurrences(of: "UTC+", with: "UTC plus ")
            .replacingOccurrences(of: "UTC-", with: "UTC minus ")
            .replacingOccurrences(of: ":", with: " hours ")
            + " minutes"
    }
}
