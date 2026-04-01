import GeografyCore
import GeografyDesign
import SwiftUI

struct TerritorialDisputesScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var selections: [String: String] = [:]
    @State private var showingResetAlert = false
    @State private var appeared = false

    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Territorial Disputes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                loadSelections()
                appeared = true
            }
            .alert("Reset to Defaults", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive, action: resetToDefaults)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All territorial dispute settings will be reset to their internationally recognized defaults.")
            }
    }
}

// MARK: - Subviews
private extension TerritorialDisputesScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                introCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4), value: appeared)

                ForEach(
                    Array(TerritorialDispute.grouped().enumerated()),
                    id: \.element.region.rawValue
                ) { index, group in
                    regionSection(group.region, disputes: group.disputes)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.4).delay(0.06 * Double(index + 1)), value: appeared)
                }

                resetButton
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.30), value: appeared)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
    }

    var disclaimerText: String {
        "Choose how disputed territories appear on maps. "
        + "Settings reflect your personal preference — not a political statement. "
        + "Defaults follow international consensus."
    }

    var introCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Color.warning.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "globe.europe.africa.fill")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.warning)
                    }
                    Text("About This Setting")
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }

                Text(disclaimerText)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.accent.opacity(0.8))
                    Text("Note: Abkhazia and South Ossetia are treated as Georgia.")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .padding(DesignSystem.Spacing.xs)
                .background(
                    DesignSystem.Color.accent.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
    }

    func regionSection(_ region: TerritorialDispute.Region, disputes: [TerritorialDispute]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(region.rawValue.uppercased())
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)

            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(disputes.enumerated()), id: \.element.id) { index, dispute in
                        disputeRow(dispute)

                        if index < disputes.count - 1 {
                            Divider()
                                .background(DesignSystem.Color.cardBackgroundHighlighted)
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    func disputeRow(_ dispute: TerritorialDispute) -> some View {
        Menu {
            ForEach(dispute.options, id: \.key) { option in
                Button {
                    hapticsService.impact(.light)
                    let newValue = option.key
                    selections[dispute.id] = newValue
                    UserDefaults.standard.set(newValue, forKey: dispute.userDefaultsKey)
                } label: {
                    let isSelected = (selections[dispute.id] ?? dispute.defaultOptionKey) == option.key
                    Label(option.label, systemImage: isSelected ? "checkmark" : "flag")
                }
            }
        } label: {
            disputeRowLabel(dispute)
        }
        .buttonStyle(.plain)
    }

    func disputeRowLabel(_ dispute: TerritorialDispute) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                flagBadge(dispute.flag)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dispute.name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text(currentSelectionLabel(for: dispute))
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.accent)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Text(dispute.description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.leading, 44)
        }
        .padding(DesignSystem.Spacing.md)
        .contentShape(Rectangle())
    }

    func flagBadge(_ flag: String) -> some View {
        Text(flag)
            .font(DesignSystem.Font.iconMedium)
            .frame(width: 36, height: 36)
    }

    var resetButton: some View {
        Button {
            showingResetAlert = true
        } label: {
            Text("Reset to Defaults")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.error)
                .frame(maxWidth: .infinity)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Actions
private extension TerritorialDisputesScreen {
    func currentSelectionLabel(for dispute: TerritorialDispute) -> String {
        let key = selections[dispute.id] ?? dispute.defaultOptionKey
        return dispute.options.first { $0.key == key }?.label ?? key
    }

    func loadSelections() {
        for dispute in TerritorialDispute.all {
            let stored = UserDefaults.standard.string(forKey: dispute.userDefaultsKey)
            if let stored, dispute.options.contains(where: { $0.key == stored }) {
                selections[dispute.id] = stored
            } else {
                selections[dispute.id] = dispute.defaultOptionKey
            }
        }
    }

    func resetToDefaults() {
        hapticsService.impact(.medium)
        for dispute in TerritorialDispute.all {
            UserDefaults.standard.set(dispute.defaultOptionKey, forKey: dispute.userDefaultsKey)
            selections[dispute.id] = dispute.defaultOptionKey
        }
    }
}

// MARK: - Preview
#Preview {
    TerritorialDisputesScreen()
}
