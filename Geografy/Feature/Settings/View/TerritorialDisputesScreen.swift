import SwiftUI

struct TerritorialDisputesScreen: View {
    @AppStorage("territory_somaliland") private var somaliland = "merge"
    @AppStorage("territory_western_sahara") private var westernSahara = "merge"
    @AppStorage("territory_northern_cyprus") private var northernCyprus = "merge"
    @AppStorage("territory_kosovo") private var kosovo = "merge"
    @AppStorage("territory_palestine") private var palestine = "merge"

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                territoryRow(
                    flag: "🇸🇴",
                    name: "Somaliland",
                    parent: "Somalia",
                    selection: $somaliland,
                )
                territoryRow(
                    flag: "🇪🇭",
                    name: "Western Sahara",
                    parent: "Morocco",
                    selection: $westernSahara,
                )
                territoryRow(
                    flag: "🇨🇾",
                    name: "Northern Cyprus",
                    parent: "Cyprus",
                    selection: $northernCyprus,
                )
                territoryRow(
                    flag: "🇽🇰",
                    name: "Kosovo",
                    parent: "Serbia",
                    selection: $kosovo,
                )
                territoryRow(
                    flag: "🇵🇸",
                    name: "Palestine",
                    parent: "Israel",
                    selection: $palestine,
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Territorial Disputes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Subviews

private extension TerritorialDisputesScreen {
    func territoryRow(
        flag: String,
        name: String,
        parent: String,
        selection: Binding<String>
    ) -> some View {
        GeoCard {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(flag)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(name)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text(parent)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Spacer()

                Picker("Status", selection: selection) {
                    Text("Part of \(parent)")
                        .tag("merge")
                    Text("Separate")
                        .tag("separate")
                }
                .tint(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TerritorialDisputesScreen()
    }
}
