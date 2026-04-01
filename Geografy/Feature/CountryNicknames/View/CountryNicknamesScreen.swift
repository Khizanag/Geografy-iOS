import SwiftUI
import GeografyDesign
import GeografyCore

struct CountryNicknamesScreen: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(CountryDataService.self) private var countryDataService

    @State private var nicknamesService = CountryNicknamesService()
    @State private var searchQuery = ""
    @State private var selectedCategory: NicknameCategory?
    @State private var expandedNicknameID: String?
    @State private var isQuizMode = false

    private var filteredNicknames: [CountryNickname] {
        nicknamesService.filteredNicknames(query: searchQuery, category: selectedCategory)
    }

    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Country Nicknames")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, prompt: "Search nicknames…")
            .sheet(isPresented: $isQuizMode) {
                NicknameQuizScreen(nicknames: nicknamesService.nicknames, countryDataService: countryDataService)
            }
    }
}

// MARK: - Subviews
private extension CountryNicknamesScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                categoryFilter
                quizBanner
                    .padding(.horizontal, DesignSystem.Spacing.md)
                if filteredNicknames.isEmpty, !searchQuery.isEmpty {
                    ContentUnavailableView.search(text: searchQuery)
                } else {
                    nicknamesList
                        .padding(.horizontal, DesignSystem.Spacing.md)
                }
                Spacer(minLength: DesignSystem.Spacing.xxl)
            }
            .padding(.top, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
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
                    .font(DesignSystem.Font.caption)
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
                    .font(DesignSystem.Font.micro)
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
                .font(DesignSystem.Font.nano)
            Text(category.rawValue)
                .font(DesignSystem.Font.nano.weight(.semibold))
        }
        .foregroundStyle(DesignSystem.Color.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
    }

    var emptyState: some View {
        ContentUnavailableView(
            "No nicknames found",
            systemImage: "magnifyingglass",
            description: Text("Try a different search term or category filter.")
        )
    }
}
