import SwiftUI

struct TVFeedScreen: View {
    let countryDataService: CountryDataService

    @State private var service = FeedService()

    var body: some View {
        List {
            ForEach(service.items) { item in
                feedRow(item)
            }
        }
        .navigationTitle("Feed")
        .task { service.loadFeed() }
    }
}

// MARK: - Subviews

private extension TVFeedScreen {
    func feedRow(_ item: FeedItem) -> some View {
        HStack(spacing: 20) {
            Image(systemName: item.icon)
                .font(.system(size: 24))
                .foregroundStyle(item.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(item.type.label)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(item.color)
                        .textCase(.uppercase)

                    if let code = item.countryCode {
                        FlagView(countryCode: code, height: 20)
                    }
                }

                Text(item.title)
                    .font(.system(size: 22, weight: .semibold))

                Text(item.body)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }
}
