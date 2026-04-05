import Geografy_Core_DesignSystem
import Geografy_Feature_OceanExplorer
import SwiftUI

struct OceanScreen: View {
    private let service = OceanService()

    var body: some View {
        List {
            Section("Oceans") {
                ForEach(service.oceansList) { ocean in
                    oceanRow(ocean)
                }
            }

            Section("Seas") {
                ForEach(service.seasList) { ocean in
                    oceanRow(ocean)
                }
            }
        }
        .navigationTitle("Oceans & Seas")
    }
}

// MARK: - Subviews
private extension OceanScreen {
    func oceanRow(_ ocean: Ocean) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: ocean.icon)
                    .font(DesignSystem.Font.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(ocean.name)
                    .font(DesignSystem.Font.system(size: 24, weight: .bold))

                Spacer()

                Text("\(Int(ocean.area).formatted()) km\u{00B2}")
                    .font(DesignSystem.Font.system(size: 20, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            HStack(spacing: DesignSystem.Spacing.xl) {
                Label(
                    "Avg depth: \(Int(ocean.averageDepth).formatted())m",
                    systemImage: "arrow.down"
                )
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.secondary)

                Label(
                    "Max depth: \(Int(ocean.maxDepth).formatted())m",
                    systemImage: "arrow.down.to.line"
                )
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(.secondary)
            }

            Text(ocean.funFact)
                .font(DesignSystem.Font.system(size: 22))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .lineLimit(2)
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
    }
}
