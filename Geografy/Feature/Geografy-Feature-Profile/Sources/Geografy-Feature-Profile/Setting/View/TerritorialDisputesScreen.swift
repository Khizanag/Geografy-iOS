import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct TerritorialDisputesScreen: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(GeoJSONCache.self) private var geoJSONCache

    @State private var selections: [String: String] = [:]
    @State private var hasChanges = false
    @State private var showingResetAlert = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Territorial Disputes")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadSelections() }
            // Once, on the way out, so trying several options doesn't parse the map for each.
            .onDisappear { if hasChanges { geoJSONCache.invalidate() } }
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
                    .phaseEntrance()

                ForEach(
                    Array(TerritorialDispute.grouped().enumerated()),
                    id: \.element.region.rawValue
                ) { index, group in
                    regionSection(group.region, disputes: group.disputes)
                        .phaseEntrance(index: index + 1)
                }

                resetButton
                    .phaseEntrance(index: 5)
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
            introCardContent
        }
    }

    var introCardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            introCardHeader
            introCardDisclaimer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
    }

    var introCardHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge("globe.europe.africa.fill", color: DesignSystem.Color.warning, size: .small)
            Text("About This Setting")
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    var introCardDisclaimer: some View {
        Text(disclaimerText)
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    func regionSection(_ region: TerritorialDispute.Region, disputes: [TerritorialDispute]) -> some View {
        SettingsGroup(LocalizedStringKey(region.rawValue)) {
            ForEach(Array(disputes.enumerated()), id: \.element.id) { index, dispute in
                disputeRow(dispute)
                if index < disputes.count - 1 {
                    SettingsDivider()
                }
            }
        }
    }

    func disputeRow(_ dispute: TerritorialDispute) -> some View {
        Menu {
            Picker(dispute.name, selection: selectionBinding(for: dispute)) {
                ForEach(dispute.options, id: \.key) { option in
                    Text(option.label).tag(option.key)
                }
            }
        } label: {
            disputeRowLabel(dispute)
        }
        .buttonStyle(.plain)
    }

    func selectionBinding(for dispute: TerritorialDispute) -> Binding<String> {
        Binding {
            selections[dispute.id] ?? dispute.defaultOptionKey
        } set: { newValue in
            hapticsService.selection()
            selections[dispute.id] = newValue
            UserDefaults.standard.set(newValue, forKey: dispute.userDefaultsKey)
            hasChanges = true
        }
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
        GlassButton("Reset to Defaults", role: .destructive, fullWidth: true) {
            showingResetAlert = true
        }
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
        hapticsService.impact(.light)
        for dispute in TerritorialDispute.all {
            UserDefaults.standard.set(dispute.defaultOptionKey, forKey: dispute.userDefaultsKey)
            selections[dispute.id] = dispute.defaultOptionKey
        }
        hasChanges = true
    }
}

// MARK: - Preview
#Preview {
    TerritorialDisputesScreen()
}
