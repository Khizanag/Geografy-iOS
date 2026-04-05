import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Auth
import Geografy_Feature_DailyChallenge
import Geografy_Feature_Flashcard
import SwiftUI

struct HomeScreen: View {
    // MARK: - Properties
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(AuthService.self) var authService
    @Environment(FavoritesService.self) var favoritesService
    @Environment(XPService.self) var xpService
    @Environment(StreakService.self) var streakService
    @Environment(CoinService.self) private var coinService
    @Environment(FlashcardService.self) var flashcardService

    @Environment(Navigator.self) var coordinator
    @Environment(CountryDataService.self) var countryDataService
    @Environment(FeatureFlagService.self) var featureFlags

    @State var dailyChallengeService: DailyChallengeService?
    @State var collectionItem: (id: String, type: CollectionItem.ItemType, name: String)?

    // MARK: - Body
    var body: some View {
        mainFeed
            .background { AmbientBlobsView(.rich) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { await loadDailyChallenge() }
            .sheet(isPresented: collectionSheetBinding) {
                if let item = collectionItem {
                    SaveToCollectionSheet(
                        itemID: item.id,
                        itemType: item.type,
                        itemName: item.name
                    )
                }
            }
    }
}

// MARK: - Toolbar
private extension HomeScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            profileButton
        }
        ToolbarItem(placement: .principal) {
            statsButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            searchButton
        }
        ToolbarItem(placement: .topBarTrailing) {
            friendsButton
        }
    }

    var profileButton: some View {
        Button { coordinator.sheet(.profile) } label: {
            ProfileAvatarView(
                name: authService.currentProfile?.displayName ?? "Explorer",
                size: DesignSystem.Size.md
            )
        }
        .buttonStyle(.plain)
    }

    var statsButton: some View {
        Button { coordinator.sheet(.coinStore) } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                xpIndicator
                divider
                coinIndicator
            }
        }
        .buttonStyle(.glass)
    }

    var xpIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            xpProgressBar
            Text("Lv. \(xpService.currentLevel.level)")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Level \(xpService.currentLevel.level)")
        .accessibilityValue("\(Int(xpService.progressFraction * 100)) percent to next level")
    }

    var xpProgressBar: some View {
        GeometryReader { geometryReader in
            ZStack(alignment: .leading) {
                Capsule().fill(DesignSystem.Color.cardBackgroundHighlighted)
                Capsule()
                    .fill(DesignSystem.Color.accent)
                    .frame(width: geometryReader.size.width * xpService.progressFraction)
                    .animation(.easeInOut(duration: 0.5), value: xpService.progressFraction)
            }
        }
        .frame(width: 120, height: DesignSystem.Size.xs)
    }

    var coinIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "dollarsign.circle.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.warning)
                .accessibilityHidden(true)
            Text(coinService.formattedBalance)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(coinService.formattedBalance) coins")
    }

    var divider: some View {
        Rectangle()
            .fill(DesignSystem.Color.textTertiary.opacity(0.3))
            .frame(width: DesignSystem.Size.xxs, height: DesignSystem.Size.sm)
    }

    var searchButton: some View {
        Button { coordinator.sheet(.search) } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
    }

    var friendsButton: some View {
        Button { coordinator.sheet(.friends) } label: {
            Label("Friends", systemImage: "person.2")
        }
    }
}

// MARK: - Helpers
extension HomeScreen {
    var collectionSheetBinding: Binding<Bool> {
        Binding(
            get: { collectionItem != nil },
            set: { if !$0 { collectionItem = nil } }
        )
    }

    func loadDailyChallenge() async {
        let service = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await service.loadChallenge()
        dailyChallengeService = service
    }
}
