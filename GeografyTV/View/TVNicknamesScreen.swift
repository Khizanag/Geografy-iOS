import SwiftUI

struct TVNicknamesScreen: View {
    @State private var service = CountryNicknamesService()
    @State private var selectedCategory: NicknameCategory?

    private var filteredNicknames: [CountryNickname] {
        service.nicknames(for: selectedCategory)
    }

    var body: some View {
        List {
            Section {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as NicknameCategory?)
                    ForEach(NicknameCategory.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category as NicknameCategory?)
                    }
                }
            }

            Section {
                ForEach(filteredNicknames) { nickname in
                    nicknameRow(nickname)
                }
            }
        }
        .navigationTitle("Country Nicknames")
    }
}

// MARK: - Subviews

private extension TVNicknamesScreen {
    func nicknameRow(_ nickname: CountryNickname) -> some View {
        HStack(spacing: 24) {
            FlagView(countryCode: nickname.countryCode, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(nickname.nickname)
                    .font(.system(size: 22, weight: .bold))

                Text(nickname.reason)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: nickname.category.icon)
                .font(.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}
