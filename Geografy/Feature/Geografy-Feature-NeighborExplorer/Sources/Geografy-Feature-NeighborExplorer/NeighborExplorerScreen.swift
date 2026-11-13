import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct NeighborExplorerScreen: View {
    // MARK: - Init
    public init(
        country: Country
    ) {
        self.country = country
    }
    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let country: Country

    @State private var chain: [Country] = []
    @State private var destinationCode = ""
    @State private var pathResult: [Country] = []
    @State private var isSearchingPath = false
    @State private var showNoPathAlert = false
    @State private var showDestinationPicker = false

    // MARK: - Body
    public var body: some View {
        contentView
            .navigationTitle("Neighbor Explorer")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                chain = [country]
            }
            .alert("No Land Path", isPresented: $showNoPathAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There's no land border route between these countries.")
            }
    }
}

// MARK: - Content
private extension NeighborExplorerScreen {
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                chainSection
                neighborsSection
                pathFinderSection
                if !pathResult.isEmpty {
                    pathResultSection
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .screenBackground(.standard)
    }
}

// MARK: - Chain Section
private extension NeighborExplorerScreen {
    var chainSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Your Chain", icon: "link")
                .padding(.horizontal, DesignSystem.Spacing.md)
            NeighborChainView(chain: chain) { selected in
                navigateTo(selected)
            }
            Text("\(chain.count - 1) hop\(chain.count == 2 ? "" : "s") from \(country.name)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Neighbors Section
private extension NeighborExplorerScreen {
    var neighborsSection: some View {
        let current = chain.last ?? country
        let neighbors = neighborCountries(for: current)
        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(
                title: "Neighbors of \(current.name)",
                icon: "map.fill"
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            neighborsList(neighbors)
        }
    }

    @ViewBuilder
    func neighborsList(_ neighbors: [Country]) -> some View {
        if neighbors.isEmpty {
            islandNationCard
        } else {
            neighborsScrollView(neighbors)
        }
    }

    var islandNationCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "water.waves")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.blue)
                Text("Island nation — no land borders")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func neighborsScrollView(_ neighbors: [Country]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(neighbors) { neighbor in
                    neighborChip(neighbor)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollClipDisabled()
    }

    func neighborChip(_ neighbor: Country) -> some View {
        Button { appendToChain(neighbor) } label: {
            CountryFlagTile(country: neighbor)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Path Finder Section
private extension NeighborExplorerScreen {
    var pathFinderSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Six Degrees of Separation", icon: "point.3.filled.connected.trianglepath.dotted")
                .padding(.horizontal, DesignSystem.Spacing.md)
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("How many border hops from **\(country.name)** to your destination?")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    destinationPicker
                    findPathButton
                }
                .padding(DesignSystem.Spacing.md)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var destinationPicker: some View {
        Button { showDestinationPicker = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if let destination {
                    FlagView(countryCode: destination.code, height: 20, fixedWidth: true)
                }
                Text(destination?.name ?? "Select destination country")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(
                        destination == nil ? DesignSystem.Color.textSecondary : DesignSystem.Color.textPrimary
                    )
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
            )
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Destination")
        .accessibilityValue(destination?.name ?? "None")
        .sheet(isPresented: $showDestinationPicker) {
            CoordinatedNavigationStack(showCloseButton: true) {
                CountryPicker(
                    "Destination",
                    countries: countryDataService.countries.filter {
                        $0.code != country.code && $0.continent != .antarctica
                    },
                    selectedCode: destination?.code
                ) { selected in
                    destinationCode = selected.code
                    pathResult = []
                }
            }
        }
    }

    var findPathButton: some View {
        GlassButton("Find Shortest Path", systemImage: "arrow.triangle.branch", fullWidth: true) {
            findShortestPath()
        }
        .disabled(destinationCode.isEmpty || isSearchingPath)
    }

    var destination: Country? {
        destinationCode.isEmpty ? nil : countryDataService.country(for: destinationCode)
    }
}

// MARK: - Path Result Section
private extension NeighborExplorerScreen {
    var pathResultSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            let hops = pathResult.count - 1
            SectionHeaderView(title: "Shortest Path — \(hops) hops", icon: "checkmark.circle.fill")
                .padding(.horizontal, DesignSystem.Spacing.md)
            NeighborChainView(chain: pathResult) { selected in
                chain = Array(pathResult.prefix(through: pathResult.firstIndex(of: selected) ?? 0))
                pathResult = []
            }
        }
    }
}

// MARK: - Actions
private extension NeighborExplorerScreen {
    func navigateTo(_ selected: Country) {
        guard let index = chain.firstIndex(of: selected) else { return }
        chain = Array(chain.prefix(through: index))
    }

    func appendToChain(_ neighbor: Country) {
        guard !chain.contains(neighbor) else { return }
        chain.append(neighbor)
    }

    func findShortestPath() {
        guard !destinationCode.isEmpty,
              let destination = countryDataService.country(for: destinationCode)
        else { return }

        isSearchingPath = true
        pathResult = []

        Task {
            let result = bfsPath(from: country, to: destination)
            await MainActor.run {
                isSearchingPath = false
                if let result {
                    pathResult = result
                } else {
                    showNoPathAlert = true
                }
            }
        }
    }

    func bfsPath(from start: Country, to end: Country) -> [Country]? {
        guard start != end else { return [start] }

        var visited: Set<String> = [start.code]
        var queue: [[Country]] = [[start]]

        while !queue.isEmpty {
            let currentPath = queue.removeFirst()
            guard let current = currentPath.last else { continue }

            let neighborCodes = CountryNeighbors.neighbors(for: current.code)
            for code in neighborCodes {
                guard !visited.contains(code),
                      let neighbor = countryDataService.country(for: code)
                else { continue }

                let newPath = currentPath + [neighbor]
                if neighbor.code == end.code { return newPath }

                visited.insert(code)
                queue.append(newPath)

                if newPath.count > 12 { continue }
            }
        }

        return nil
    }
}

// MARK: - Helpers
private extension NeighborExplorerScreen {
    func neighborCountries(for current: Country) -> [Country] {
        CountryNeighbors.neighbors(for: current.code)
            .compactMap { countryDataService.country(for: $0) }
    }
}
