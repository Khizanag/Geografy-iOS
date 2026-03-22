import SwiftUI

struct TravelStatusPickerSheet: View {
    @Environment(TravelService.self) private var travelService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService

    let country: Country
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            statusOptions
            clearButton
        }
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.lg)
        .presentationDetents([.height(hasExistingStatus ? 270 : 220)])
        .presentationDragIndicator(.automatic)
    }
}

// MARK: - Subviews

private extension TravelStatusPickerSheet {
    var hasExistingStatus: Bool {
        travelService.status(for: country.code) != nil
    }

    var header: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Mark your travel status")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    var statusOptions: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(TravelStatus.allCases) { status in
                statusRow(status)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func statusRow(_ status: TravelStatus) -> some View {
        let isSelected = travelService.status(for: country.code) == status
        return Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            travelService.set(status: isSelected ? nil : status, for: country.code)
            if !isSelected {
                awardTravelXP(for: status)
                checkTravelAchievements()
                isPresented = false
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(status.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: status.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(status.color)
                }
                Text(status.label)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(status.color)
                        .font(DesignSystem.Font.headline)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .fill(isSelected ? status.color.opacity(0.1) : DesignSystem.Color.cardBackgroundHighlighted)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .stroke(isSelected ? status.color.opacity(0.5) : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    // MARK: - Gamification

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

    var clearButton: some View {
        Group {
            if hasExistingStatus {
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
                .padding(.top, DesignSystem.Spacing.xxs)
            }
        }
    }
}
