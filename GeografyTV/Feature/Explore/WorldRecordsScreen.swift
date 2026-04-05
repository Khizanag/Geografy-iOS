import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_WorldRecords
import SwiftUI

struct WorldRecordsScreen: View {
    let countryDataService: CountryDataService

    @State private var selectedCategory: WorldRecordCategory?

    private var records: [WorldRecord] {
        WorldRecordsService().computeRecords(from: countryDataService.countries)
    }

    private var filteredRecords: [WorldRecord] {
        guard let selectedCategory else { return records }
        return records.filter { $0.category == selectedCategory }
    }

    var body: some View {
        List {
            Section {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as WorldRecordCategory?)
                    ForEach(WorldRecordCategory.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category as WorldRecordCategory?)
                    }
                }
            }

            Section {
                ForEach(filteredRecords) { record in
                    recordRow(record)
                }
            }
        }
        .navigationTitle("World Records")
    }
}

// MARK: - Subviews
private extension WorldRecordsScreen {
    func recordRow(_ record: WorldRecord) -> some View {
        HStack(spacing: 24) {
            FlagView(countryCode: record.countryCode, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.system(size: 22, weight: .bold))

                Text(record.countryName)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(record.value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.accent)
        }
    }
}
