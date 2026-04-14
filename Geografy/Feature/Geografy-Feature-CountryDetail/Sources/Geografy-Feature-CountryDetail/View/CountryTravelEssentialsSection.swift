import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Travel Essentials
/// Practical, traveller-focused facts that appear on every country detail
/// screen regardless of premium status: timezone, dialing code, demonym,
/// driving side, internet TLD. Countries without curated data fall back to
/// "Not available" so the layout never collapses.
extension CountryDetailScreen {
    @ViewBuilder
    var travelEssentialsSection: some View {
        let essentials = CountryTravelData.essentials(for: country.code)
        let timeZoneDisplay = CountryTravelData.timeZoneOffsetDisplay(for: country.code)

        if essentials != nil || timeZoneDisplay != nil {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Travel Essentials", premium: false)
                CardView {
                    travelEssentialsList(essentials: essentials, timeZoneDisplay: timeZoneDisplay)
                        .padding(DesignSystem.Spacing.sm)
                }
            }
        }
    }
}

// MARK: - Essential rows
private extension CountryDetailScreen {
    @ViewBuilder
    func travelEssentialsList(
        essentials: CountryTravelData.Essentials?,
        timeZoneDisplay: String?
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            timezoneRow(timeZoneDisplay)
            callingCodeRow(essentials?.callingCode)
            demonymRow(essentials?.demonym)
            drivingSideRow(essentials?.drivingSide)
            internetTLDRow(essentials?.internetTLD)
        }
    }

    @ViewBuilder
    func timezoneRow(_ display: String?) -> some View {
        if let display {
            travelEssentialRow(
                icon: "clock",
                label: "Timezone",
                value: display,
                accessibility: "Timezone \(accessibleUTC(display))"
            )
            Divider()
        }
    }

    @ViewBuilder
    func callingCodeRow(_ code: String?) -> some View {
        if let code {
            travelEssentialRow(
                icon: "phone.fill",
                label: "Dialing code",
                value: code,
                accessibility: "Dialing code \(code)"
            )
            Divider()
        }
    }

    @ViewBuilder
    func demonymRow(_ demonym: String?) -> some View {
        if let demonym {
            travelEssentialRow(icon: "person.2.fill", label: "Demonym", value: demonym)
            Divider()
        }
    }

    @ViewBuilder
    func drivingSideRow(_ side: CountryTravelData.DrivingSide?) -> some View {
        if let side {
            travelEssentialRow(
                icon: "steeringwheel",
                label: "Driving side",
                value: side == .left ? "Left" : "Right"
            )
            Divider()
        }
    }

    @ViewBuilder
    func internetTLDRow(_ tld: String?) -> some View {
        if let tld {
            travelEssentialRow(icon: "globe", label: "Internet TLD", value: tld)
        }
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
