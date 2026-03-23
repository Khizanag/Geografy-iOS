import SwiftUI

struct CountryNicknamesScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HapticsService.self) private var hapticsService

    @State private var nicknamesService = CountryNicknamesService()
    @State private var countryDataService = CountryDataService()
    @State private var searchQuery = ""
    @State private var selectedCategory: NicknameCategory?
    @State private var expandedNicknameID: String?
    @State private var isQuizMode = false

    private var filteredNicknames: [CountryNickname] {
        nicknamesService.filteredNicknames(query: searchQuery, category: selectedCategory)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                searchBar
                    .padding(.horizontal, DesignSystem.Spacing.md)
                categoryFilter
                quizBanner
                    .padding(.horizontal, DesignSystem.Spacing.md)
                nicknamesList
                    .padding(.horizontal, DesignSystem.Spacing.md)
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.top, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Country Nicknames")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CircleCloseButton { dismiss() }
            }
        }
        .task { countryDataService.loadCountries() }
        .sheet(isPresented: $isQuizMode) {
            NavigationStack {
                NicknameQuizScreen(nicknames: nicknamesService.nicknames, countryDataService: countryDataService)
            }
        }
    }
}

// MARK: - Subviews

private extension CountryNicknamesScreen {
    var searchBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            TextField("Search nicknames…", text: $searchQuery)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if !searchQuery.isEmpty {
                Button { searchQuery = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterChip(label: "All", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(NicknameCategory.allCases, id: \.self) { category in
                    filterChip(
                        label: category.rawValue,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func filterChip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var quizBanner: some View {
        Button {
            hapticsService.impact(.medium)
            isQuizMode = true
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "questionmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.onAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quiz Me!")
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                    Text("Can you match the nickname to the country?")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.7))
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Color.accent, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        }
        .buttonStyle(PressButtonStyle())
    }

    var nicknamesList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if filteredNicknames.isEmpty {
                emptyState
            } else {
                ForEach(filteredNicknames) { nickname in
                    nicknameCard(nickname)
                }
            }
        }
    }

    func nicknameCard(_ nickname: CountryNickname) -> some View {
        let isExpanded = expandedNicknameID == nickname.id
        let countryName = countryDataService.countries
            .first { $0.code == nickname.countryCode }?.name ?? nickname.countryCode

        return Button {
            hapticsService.impact(.light)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                expandedNicknameID = isExpanded ? nil : nickname.id
            }
        } label: {
            CardView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    nicknameCardHeader(nickname, countryName: countryName, isExpanded: isExpanded)
                    if isExpanded {
                        nicknameCardDetail(nickname, countryName: countryName)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    func nicknameCardHeader(_ nickname: CountryNickname, countryName: String, isExpanded: Bool) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            FlagView(countryCode: nickname.countryCode, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            VStack(alignment: .leading, spacing: 2) {
                Text("\"\(nickname.nickname)\"")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(countryName)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                categoryBadge(nickname.category)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    func nicknameCardDetail(_ nickname: CountryNickname, countryName: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Divider()
            Text(nickname.reason)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func categoryBadge(_ category: NicknameCategory) -> some View {
        HStack(spacing: 3) {
            Image(systemName: category.icon)
                .font(.system(size: 9))
            Text(category.rawValue)
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
    }

    var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("No nicknames found")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxl)
    }
}
