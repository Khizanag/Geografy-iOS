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
            activeSheet = .travelPicker
        } label: {
            travelCardLabel(status: currentStatus)
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Travel Status: \(currentStatus?.label ?? "Not set")")
    }

    func travelCardLabel(status currentStatus: TravelStatus?) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill((currentStatus?.color ?? DesignSystem.Color.accent).opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: currentStatus?.icon ?? "airplane.departure")
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(currentStatus?.color ?? DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Travel Status")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(currentStatus?.label ?? "Not set")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            currentStatus != nil
                                ? DesignSystem.Color.textPrimary
                                : DesignSystem.Color.textTertiary
                        )
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
}

// MARK: - Sheet Content
extension CountryDetailScreen {
    @ViewBuilder
    func countryDetailSheetContent(for sheet: CountryDetailSheet) -> some View {
        switch sheet {
        case .travelPicker:
            TravelStatusPickerSheet(
                country: country,
                isPresented: Binding(
                    get: { activeSheet != nil },
                    set: { if !$0 { activeSheet = nil } }
                )
            )
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
