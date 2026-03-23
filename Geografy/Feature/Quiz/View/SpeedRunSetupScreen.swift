import SwiftUI

struct SpeedRunSetupScreen: View {
    @Environment(TabCoordinator.self) private var coordinator

    @AppStorage("speedrun_selectedRegion") private var selectedRegion: QuizRegion = .world

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                headerSection
                regionSection
                rulesSection
            }
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) {
            startButton
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Speed Run")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CircleCloseButton { coordinator.dismissSheet() }
            }
        }
    }
}

// MARK: - Subviews

private extension SpeedRunSetupScreen {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .fill(DesignSystem.Color.error.opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "timer")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(DesignSystem.Color.error)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Speed Run")
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text("Name every country as fast as possible")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Region")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)

            RegionSelectionBar(
                items: QuizRegion.allCases.map { $0 },
                selectedID: selectedRegion.id,
                onSelect: { selectedRegion = $0 }
            )

            Text(regionDescription)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .animation(.easeInOut(duration: 0.2), value: selectedRegion)
        }
    }

    var rulesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("How it works")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.md)

            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    ruleRow(
                        icon: "keyboard",
                        color: DesignSystem.Color.blue,
                        text: "Type country names one by one"
                    )
                    ruleRow(
                        icon: "checkmark.circle.fill",
                        color: DesignSystem.Color.success,
                        text: "Each correct name flashes green instantly"
                    )
                    ruleRow(
                        icon: "timer",
                        color: DesignSystem.Color.error,
                        text: "Timer counts up — finish faster for more XP"
                    )
                    ruleRow(
                        icon: "trophy.fill",
                        color: DesignSystem.Color.warning,
                        text: "Best times submitted to Game Center"
                    )
                }
                .padding(DesignSystem.Spacing.md)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func ruleRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var startButton: some View {
        GlassButton("Start Speed Run", systemImage: "timer", fullWidth: true) {
            coordinator.dismissSheet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                coordinator.presentFullScreen(.speedRunSession(region: selectedRegion))
            }
        }
    }
}

// MARK: - Helpers

private extension SpeedRunSetupScreen {
    var regionDescription: String {
        switch selectedRegion {
        case .world: "Name all 195 countries in the world"
        case .africa: "Name all 54 countries in Africa"
        case .asia: "Name all 48 countries in Asia"
        case .europe: "Name all 44 countries in Europe"
        case .northAmerica: "Name all 23 countries in North America"
        case .southAmerica: "Name all 12 countries in South America"
        case .oceania: "Name all 14 countries in Oceania"
        }
    }
}
