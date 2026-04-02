import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import Geografy_Feature_Feed
import SwiftUI

struct FeedScreen: View {
    let countryDataService: CountryDataService

    @State private var service = FeedService()
    @State private var selectedItem: FeedItem?

    var body: some View {
        List(service.items) { item in
            Button {
                selectedItem = item
            } label: {
                HStack(spacing: 24) {
                    Image(systemName: item.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(item.color)
                        .frame(width: 50)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.type.label)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(item.color)
                            .textCase(.uppercase)

                        Text(item.title)
                            .font(.system(size: 26, weight: .bold))

                        Text(item.body)
                            .font(.system(size: 22))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    if let code = item.countryCode {
                        FlagView(countryCode: code, height: 36)
                    }
                }
            }
        }
        .navigationTitle("Feed")
        .task { service.loadFeed() }
        .sheet(item: $selectedItem) { item in
            FeedDetailView(item: item, countryDataService: countryDataService)
        }
    }
}

// MARK: - Detail
struct FeedDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let item: FeedItem
    let countryDataService: CountryDataService

    var body: some View {
        // swiftlint:disable:next closure_body_length
        NavigationStack {
            // swiftlint:disable:next closure_body_length
            List {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            Image(systemName: item.icon)
                                .font(.system(size: 40))
                                .foregroundStyle(item.color)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.type.label)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(item.color)
                                    .textCase(.uppercase)

                                if let code = item.countryCode {
                                    FlagView(countryCode: code, height: 28)
                                }
                            }
                        }

                        Text(item.title)
                            .font(.system(size: 36, weight: .bold))
                    }
                }

                Section {
                    Text(item.body)
                        .font(.system(size: 24))
                }

                if let code = item.countryCode,
                   let country = countryDataService.countries.first(where: { $0.code == code }) {
                    Section("Related Country") {
                        HStack(spacing: 16) {
                            FlagView(countryCode: country.code, height: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.name)
                                    .font(.system(size: 24, weight: .semibold))

                                Text("\(country.capital) · \(country.continent.displayName)")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(item.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onExitCommand { dismiss() }
    }
}
