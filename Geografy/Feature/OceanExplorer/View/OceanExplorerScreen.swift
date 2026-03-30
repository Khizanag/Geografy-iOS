import SwiftUI

struct OceanExplorerScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedSegment = 0
    @State private var expandedOceanId: String?
    @State private var blobAnimating = false

    private let oceanService = OceanService()
    private let segments = ["Oceans", "Seas"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                segmentedPicker
                oceanList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Ocean Explorer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startBlobAnimation() }
    }
}

// MARK: - Subviews
private extension OceanExplorerScreen {
    var segmentedPicker: some View {
        Picker("Type", selection: $selectedSegment) {
            ForEach(segments.indices, id: \.self) { index in
                Text(segments[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
    }

    var oceanList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            let items = selectedSegment == 0 ? oceanService.oceansList : oceanService.seasList
            ForEach(items) { ocean in
                oceanRow(ocean)
            }
        }
    }

    func oceanRow(_ ocean: Ocean) -> some View {
        let isExpanded = expandedOceanId == ocean.id
        return CardView {
            VStack(spacing: 0) {
                summaryRow(ocean: ocean, isExpanded: isExpanded)
                if isExpanded {
                    detailContent(ocean: ocean)
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                expandedOceanId = isExpanded ? nil : ocean.id
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func summaryRow(ocean: Ocean, isExpanded: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            oceanIcon(icon: ocean.icon)
            oceanSummary(ocean: ocean)
            Spacer()
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
    }

    func oceanIcon(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 28
                    )
                )
                .frame(width: 50, height: 50)
            Image(systemName: icon)
                .font(DesignSystem.Font.iconDefault)
                .foregroundStyle(DesignSystem.Color.blue)
        }
    }

    func oceanSummary(ocean: Ocean) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ocean.name)
                .font(DesignSystem.Font.headline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            HStack(spacing: DesignSystem.Spacing.xs) {
                Label(formatArea(ocean.area), systemImage: "square.dashed")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text("·")
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .font(DesignSystem.Font.caption2)
                Label(formatDepth(ocean.averageDepth) + " avg", systemImage: "arrow.down.to.line")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    func detailContent(ocean: Ocean) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.md)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                statsGrid(ocean: ocean)
                borderingContinentsRow(ocean: ocean)
                funFactRow(ocean: ocean)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    func statsGrid(ocean: Ocean) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            statTile(
                label: "Area",
                value: formatArea(ocean.area),
                icon: "square.dashed"
            )
            statTile(
                label: "Avg Depth",
                value: formatDepth(ocean.averageDepth),
                icon: "arrow.down.to.line"
            )
            statTile(
                label: "Max Depth",
                value: formatDepth(ocean.maxDepth),
                icon: "arrow.down.circle"
            )
        }
    }

    func statTile(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(DesignSystem.Font.iconXS)
                .foregroundStyle(DesignSystem.Color.blue)
            Text(value)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.blue.opacity(0.08),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }

    func borderingContinentsRow(ocean: Ocean) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Bordering Continents", systemImage: "map")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(ocean.borderingContinents.joined(separator: ", "))
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

    func funFactRow(ocean: Ocean) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.iconXS)
                .foregroundStyle(DesignSystem.Color.warning)
                .padding(.top, 2)
            Text(ocean.funFact)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.warning.opacity(0.08),
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }

    var ambientBlobs: some View {
        ZStack {
            RadialGradient(
                colors: [DesignSystem.Color.blue.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            RadialGradient(
                colors: [DesignSystem.Color.indigo.opacity(0.14), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .scaleEffect(blobAnimating ? 1.05 : 0.95)
        .animation(reduceMotion ? .default : .easeInOut(duration: 4).repeatForever(autoreverses: true), value: blobAnimating)
    }
}

// MARK: - Helpers
private extension OceanExplorerScreen {
    func startBlobAnimation() {
        blobAnimating = true
    }

    func formatArea(_ area: Double) -> String {
        let millions = area / 1_000_000
        return String(format: "%.1fM km²", millions)
    }

    func formatDepth(_ depth: Double) -> String {
        let kilometers = depth / 1_000
        return String(format: "%.1f km", kilometers)
    }
}
