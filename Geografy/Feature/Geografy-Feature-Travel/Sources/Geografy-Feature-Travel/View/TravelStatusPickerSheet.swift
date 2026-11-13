import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct TravelStatusPickerSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(TravelService.self) private var travelService
    @Environment(XPService.self) private var xpService
    @Environment(AchievementService.self) private var achievementService
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let country: Country

    // MARK: - Init
    public init(country: Country) {
        self.country = country
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            header
            statusOptions
            if hasExistingStatus {
                removeButton
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.md)
        .fittedSheet()
        .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: currentStatus)
    }
}

// MARK: - Subviews
private extension TravelStatusPickerSheet {
    var currentStatus: TravelStatus? {
        travelService.status(for: country.code)
    }

    var hasExistingStatus: Bool {
        currentStatus != nil
    }

    var header: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: 56)
                .geoShadow(.elevated)
            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(country.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                Text("Travel status")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    var statusOptions: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return GlassEffectContainer(spacing: DesignSystem.Spacing.sm) {
            layout {
                ForEach(TravelStatus.allCases) { status in
                    statusTile(status)
                }
            }
        }
    }

    func statusTile(_ status: TravelStatus) -> some View {
        let isSelected = currentStatus == status
        let shape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
        return Button {
            select(status, isSelected: isSelected)
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: status.icon)
                    .font(DesignSystem.Font.title)
                    .foregroundStyle(status.color)
                    .symbolEffect(.bounce, value: reduceMotion ? false : isSelected)
                    .accessibilityHidden(true)
                Text(status.label)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(status.detail)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            // The checkmark says "selected" without relying on the tint's color.
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(status.color)
                        .padding(DesignSystem.Spacing.sm)
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityHidden(true)
                }
            }
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .glassEffect(
            isSelected ? .regular.tint(status.color.opacity(0.3)).interactive() : .regular.interactive(),
            in: shape
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Clears this status" : "Sets this status")
    }

    var removeButton: some View {
        Button(role: .destructive) {
            hapticsService.impact(.light)
            travelService.set(status: nil, for: country.code)
            dismiss()
        } label: {
            Label("Remove Status", systemImage: "xmark")
                .font(DesignSystem.Font.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
        .tint(DesignSystem.Color.destructive)
    }
}

// MARK: - Actions
private extension TravelStatusPickerSheet {
    func select(_ status: TravelStatus, isSelected: Bool) {
        hapticsService.impact(.light)
        travelService.set(status: isSelected ? nil : status, for: country.code)
        guard !isSelected else { return }
        awardTravelXP(for: status)
        checkTravelAchievements()
        dismiss()
    }
}

// MARK: - Status Copy
private extension TravelStatus {
    var detail: String {
        switch self {
        case .visited: "I've been there"
        case .wantToVisit: "It's on my list"
        }
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
