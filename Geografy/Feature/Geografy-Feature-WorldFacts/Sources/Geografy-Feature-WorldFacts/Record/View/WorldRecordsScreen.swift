import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WorldRecordsScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var records: [WorldRecord] = []

    private let worldRecordsService = WorldRecordsService()

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .task {
                records = worldRecordsService.computeRecords(from: countryDataService.countries)
            }
    }
}

// MARK: - Subviews
private extension WorldRecordsScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
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
                .padding(.horizontal, DesignSystem.Spacing.md)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(records) { record in
                    recordRow(record)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func recordRow(_ record: WorldRecord) -> some View {
        let country = countryDataService.country(for: record.countryCode)
        return Button {
            if let found = country {
                coordinator.push(.countryDetail(found))
            }
        } label: {
            CardView {
                recordRowContent(record: record, country: country)
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(country == nil)
    }

    func recordRowContent(record: WorldRecord, country: Country?) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            IconBadge(record.category.icon, size: .medium)
            recordInfo(record: record)
            Spacer()
            if let country {
                FlagView(countryCode: country.code, height: 28)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.title): \(record.countryName), \(record.value)")
    }

    func recordInfo(record: WorldRecord) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(record.title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Text(record.countryName)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            Text(record.value)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .fontWeight(.semibold)
        }
    }
}
