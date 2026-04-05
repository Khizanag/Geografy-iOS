import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Feature_CountryNicknames
import SwiftUI

struct NicknamesScreen: View {
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
private extension NicknamesScreen {
    func nicknameRow(_ nickname: CountryNickname) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            FlagView(countryCode: nickname.countryCode, height: 44)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(nickname.nickname)
                    .font(DesignSystem.Font.system(size: 22, weight: .bold))

                Text(nickname.reason)
                    .font(DesignSystem.Font.system(size: 22))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: nickname.category.icon)
                .font(DesignSystem.Font.system(size: 20))
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}
