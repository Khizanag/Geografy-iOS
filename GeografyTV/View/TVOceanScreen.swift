import SwiftUI

struct TVOceanScreen: View {
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
private extension TVOceanScreen {
    func oceanRow(_ ocean: Ocean) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: ocean.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(DesignSystem.Color.accent)

                Text(ocean.name)
                    .font(.system(size: 24, weight: .bold))

                Spacer()

                Text("\(Int(ocean.area).formatted()) km²")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            HStack(spacing: 32) {
                Label("Avg depth: \(Int(ocean.averageDepth).formatted())m", systemImage: "arrow.down")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)

                Label("Max depth: \(Int(ocean.maxDepth).formatted())m", systemImage: "arrow.down.to.line")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }

            Text(ocean.funFact)
                .font(.system(size: 18))
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
