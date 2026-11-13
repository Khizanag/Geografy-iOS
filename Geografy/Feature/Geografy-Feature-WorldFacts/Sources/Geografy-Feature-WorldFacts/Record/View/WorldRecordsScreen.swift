import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WorldRecordsScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var records: [WorldRecord] = []

    private let worldRecordsService = WorldRecordsService()

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            // Keyed on the count: opened before country data loads, the records fill in once it arrives.
            .task(id: countryDataService.countries.count) {
                records = worldRecordsService.computeRecords(from: countryDataService.countries)
            }
    }
}

// MARK: - Subviews
private extension WorldRecordsScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                ForEach(WorldRecordCategory.allCases, id: \.rawValue) { category in
                    let categoryRecords = records.filter { $0.category == category }
                    if !categoryRecords.isEmpty {
                        categorySection(category: category, records: categoryRecords)
                    }
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    func categorySection(category: WorldRecordCategory, records: [WorldRecord]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: category.displayName, icon: category.icon)

            // A category's extremes sit side by side, so "largest" and "smallest" read as one fact.
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
                : AnyLayout(HStackLayout(alignment: .top, spacing: DesignSystem.Spacing.sm))
            layout {
                ForEach(records) { record in
                    recordTile(record)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func recordTile(_ record: WorldRecord) -> some View {
        let country = countryDataService.country(for: record.countryCode)
        return Button {
            if let country {
                coordinator.push(.countryDetail(country))
            }
        } label: {
            CardView {
                recordTileContent(record)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(country == nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(record.title): \(record.countryName), \(record.value)")
        .accessibilityAddTraits(.isButton)
    }

    func recordTileContent(_ record: WorldRecord) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(record.title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            FlagView(countryCode: record.countryCode, height: DesignSystem.Size.Flag.compact)
                .geoShadow(.subtle)
                .padding(.vertical, DesignSystem.Spacing.xxs)

            Text(record.countryName)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(record.value)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }
}
