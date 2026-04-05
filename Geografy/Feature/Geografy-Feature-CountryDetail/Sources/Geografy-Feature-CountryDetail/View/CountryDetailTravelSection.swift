import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_CountryProfile
import Geografy_Feature_Travel
import SwiftUI

// MARK: - Travel
extension CountryDetailScreen {
    var travelSection: some View {
        let currentStatus = travelService.status(for: country.code)
        return Button {
            hapticsService.impact(.light)
            coordinator.sheet(.travelStatusPicker(country))
        } label: {
            travelCardLabel(status: currentStatus)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Travel Status: \(currentStatus?.label ?? "Not set")")
    }

    func travelCardLabel(status currentStatus: TravelStatus?) -> some View {
        let color = currentStatus?.color ?? DesignSystem.Color.accent

        return CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                travelStatusIcon(color: color, icon: currentStatus?.icon ?? "airplane.departure")
                travelStatusText(label: currentStatus?.label, hasStatus: currentStatus != nil)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }

    func travelStatusIcon(color: Color, icon: String) -> some View {
        Circle()
            .fill(color.opacity(0.15))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: icon)
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(color)
            }
    }

    func travelStatusText(label: String?, hasStatus: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Travel Status")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(label ?? "Not set")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(hasStatus ? DesignSystem.Color.textPrimary : DesignSystem.Color.textTertiary)
        }
    }
}

// MARK: - Sheet Content
extension CountryDetailScreen {
    @ViewBuilder
    func countryDetailSheetContent(for sheet: CountryDetailSheet) -> some View {
        switch sheet {
        case .info(let item):
            propertyDetailSheet(for: item)
        case .deepDive:
            CountryProfileScreen(
                country: country,
                profile: profileService.profile(for: country.code)
            )
        }
    }

    func propertyDetailSheet(for item: InfoItem) -> some View {
        PropertyDetailSheet(
            icon: item.icon,
            title: item.title,
            value: item.value,
            supportsMap: item.supportsMap,
            mapButtonTitle: item.mapButtonTitle,
            onShowMap: {
                activeSheet = nil
                coordinator.cover(.mapFullScreen(continentFilter: country.continent.displayName))
            },
            actionButtonTitle: item.actionButtonTitle,
            actionButtonIcon: item.actionButtonIcon,
            onAction: item.onAction
        )
    }
}

// MARK: - Gamification
extension CountryDetailScreen {
    func trackExploration() {
        let key = "explored_countries_\(xpService.currentUserID)"
        var explored = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        guard !explored.contains(country.code) else { return }
        explored.insert(country.code)
        UserDefaults.standard.set(Array(explored), forKey: key)
        xpService.award(5, source: .countryExplored)
        achievementService.checkExplorerAchievements(totalExplored: explored.count)
    }
}
