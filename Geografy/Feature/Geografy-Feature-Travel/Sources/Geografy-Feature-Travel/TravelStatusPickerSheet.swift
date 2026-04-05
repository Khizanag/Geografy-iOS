import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TravelStatusPickerSheet: View {
    // MARK: - Properties
    @Environment(TravelService.self) private var travelService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) private var hapticsService

    public let country: Country
    @Binding public var isPresented: Bool

    // MARK: - Init
    public init(country: Country, isPresented: Binding<Bool>) {
        self.country = country
        _isPresented = isPresented
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider().padding(.horizontal, DesignSystem.Spacing.md)
            statusOptions
            if hasExistingStatus {
                Divider().padding(.horizontal, DesignSystem.Spacing.md)
                clearButton
            }
        }
        .padding(.top, DesignSystem.Spacing.sm)
        .padding(.bottom, DesignSystem.Spacing.md)
        .presentationDetents([.height(hasExistingStatus ? 240 : 200)])
        .presentationCornerRadius(DesignSystem.CornerRadius.extraLarge)
    }
}

// MARK: - Subviews
private extension TravelStatusPickerSheet {
    var hasExistingStatus: Bool {
        travelService.status(for: country.code) != nil
    }

    var header: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Set travel status")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    var statusOptions: some View {
        VStack(spacing: 0) {
            ForEach(TravelStatus.allCases) { status in
                statusRow(status)
            }
        }
    }

    func statusRow(_ status: TravelStatus) -> some View {
        let isSelected = travelService.status(for: country.code) == status
        return Button {
            hapticsService.impact(.medium)
            travelService.set(status: isSelected ? nil : status, for: country.code)
            if !isSelected {
                awardTravelXP(for: status)
                checkTravelAchievements()
                isPresented = false
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: status.icon)
                    .font(DesignSystem.Font.iconSmall)
                    .foregroundStyle(status.color)
                    .frame(width: 24)
                Text(status.label)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.iconXS.weight(.semibold))
                        .foregroundStyle(status.color)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
    }

    var clearButton: some View {
        Button {
            hapticsService.impact(.light)
            travelService.set(status: nil, for: country.code)
            isPresented = false
        } label: {
            Text("Remove Status")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Gamification
private extension TravelStatusPickerSheet {
    func awardTravelXP(for status: TravelStatus) {
        let key = "travel_xp_awarded"
        var awarded = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        let entryKey = "\(country.code):\(status.rawValue)"
        guard !awarded.contains(entryKey) else { return }
        awarded.insert(entryKey)
        UserDefaults.standard.set(Array(awarded), forKey: key)
        switch status {
        case .visited:
            xpService.award(20, source: .travelVisited)
        case .wantToVisit:
            xpService.award(5, source: .travelWantToVisit)
        }
    }

    func checkTravelAchievements() {
        achievementService.checkTravelAchievements(
            visitedCount: travelService.visitedCodes.count,
            wantCount: travelService.wantToVisitCodes.count
        )
    }
}
