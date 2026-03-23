import SwiftUI

struct TerritorialDisputesScreen: View {
    @Environment(HapticsService.self) private var hapticsService

    @State private var selections: [String: String] = [:]
    @State private var showingResetAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                introCard

                ForEach(TerritorialDispute.grouped(), id: \.region.rawValue) { group in
                    regionSection(group.region, disputes: group.disputes)
                }

                resetButton
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Territorial Disputes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear(perform: loadSelections)
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
    var introCard: some View {
        CardView {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("About This Setting")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text("Choose how disputed territories appear on the map. Defaults reflect international consensus.")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignSystem.Spacing.md)
        }
    }

    func regionSection(_ region: TerritorialDispute.Region, disputes: [TerritorialDispute]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(region.rawValue.uppercased())
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                flagBadge(dispute.flag)

                Text(dispute.name)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                Picker("", selection: selectionBinding(for: dispute)) {
                    ForEach(dispute.options, id: \.key) { option in
                        Text(option.label).tag(option.key)
                    }
                }
                .pickerStyle(.menu)
                .tint(DesignSystem.Color.accent)
            }

            Text(dispute.description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 44)
        }
        .padding(DesignSystem.Spacing.md)
    }

    func flagBadge(_ flag: String) -> some View {
        Text(flag)
            .font(DesignSystem.Font.title2)
            .frame(width: DesignSystem.Spacing.xl, height: DesignSystem.Spacing.xl)
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
    }
}

// MARK: - Actions

private extension TerritorialDisputesScreen {
    func selectionBinding(for dispute: TerritorialDispute) -> Binding<String> {
        Binding(
            get: { selections[dispute.id] ?? dispute.defaultOptionKey },
            set: { newValue in
                hapticsService.impact(.light)
                selections[dispute.id] = newValue
                UserDefaults.standard.set(newValue, forKey: dispute.userDefaultsKey)
            }
        )
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
    NavigationStack {
        TerritorialDisputesScreen()
    }
}
