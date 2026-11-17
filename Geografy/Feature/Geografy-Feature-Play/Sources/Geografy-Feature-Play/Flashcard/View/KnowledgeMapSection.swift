import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Map
import Geografy_Core_Service
import SwiftUI

/// Each continent's map colored by how well its countries are known, with how many are mastered.
struct KnowledgeMapSection: View {
    // MARK: - Properties
    @Environment(FlashcardService.self) private var flashcardService
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var outlines: [Country.Continent: ContinentOutline] = [:]

    private static let continents = Country.Continent.allCases.filter { $0 != .antarctica }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Mastery")
            legend
            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(Self.continents, id: \.self) { continent in
                    continentCard(continent)
                }
            }
        }
        .task { await loadOutlines() }
    }
}

// MARK: - Subviews
private extension KnowledgeMapSection {
    var legend: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(CountryKnowledge.allCases, id: \.self) { level in
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    Circle()
                        .fill(level.color)
                        .frame(width: DesignSystem.Spacing.xs, height: DesignSystem.Spacing.xs)
                    Text(level.title)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    func continentCard(_ continent: Country.Continent) -> some View {
        let countries = countryDataService.countries.filter { $0.continent == continent }
        let levels = Dictionary(
            uniqueKeysWithValues: countries.map { ($0.code, flashcardService.knowledge(of: $0.code)) }
        )
        let knownCount = levels.values.count { $0 == .known }
        return CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Group {
                    if let outline = outlines[continent] {
                        ContinentOutlineView(
                            outline: outline,
                            fill: CountryKnowledge.unseen.color,
                            countryColors: levels.filter { $0.value != .unseen }.mapValues(\.color)
                        )
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 88)
                Text(continent.displayName)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                ShareBar(fraction: countries.isEmpty ? 0 : Double(knownCount) / Double(countries.count))
                Text("\(knownCount) of \(countries.count) mastered")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(continent.displayName))
        .accessibilityValue(Text("\(knownCount) of \(countries.count) countries mastered"))
    }

    var columns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.sm), count: count)
    }
}

// MARK: - Loading
private extension KnowledgeMapSection {
    func loadOutlines() async {
        guard outlines.isEmpty else { return }
        let shapes = await geoJSONCache.loadShapes()
        for continent in Self.continents {
            outlines[continent] = await ContinentOutline.puzzleOutline(for: continent, shapes: shapes)
        }
    }
}
