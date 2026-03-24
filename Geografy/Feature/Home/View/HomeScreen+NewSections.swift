import SwiftUI

// MARK: - Discover Section View

extension HomeScreen {
    @ViewBuilder
    func discoverSectionView(for section: HomeSection) -> some View {
        switch section {
        case .independenceTimeline: independenceTimelineSection
        case .economyExplorer: economyExplorerSection
        case .geographyFeatures: geographyFeaturesSection
        default: EmptyView()
        }
    }

    @ViewBuilder
    func newFeatureSectionView(for section: HomeSection) -> some View {
        switch section {
        case .cultureExplorer: cultureExplorerSection
        case .landmarkGallery: landmarkGallerySection
        case .quotes: quotesSection
        case .mapColoring: mapColoringSection
        case .countryNicknames: countryNicknamesSection
        case .wordSearch: wordSearchSection
        case .borderChallenge: borderChallengeSection
        default: discoverSectionView(for: section)
        }
    }
}

// MARK: - World Records Section

extension HomeScreen {
    var worldRecordsSection: some View {
        HomeWorldRecordsCard {
            coordinator.push(.worldRecords)
        }
    }
}

// MARK: - Organizations Section

extension HomeScreen {
    var orgsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HomeOrgsCard(
                onOrgTap: { coordinator.present(.organizationDetail($0)) },
                onSeeAll: { coordinator.present(.organizations) }
            )
        }
    }
}

// MARK: - Daily Challenge Section

extension HomeScreen {
    var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Daily Challenge")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeDailyChallengeCard(
                streak: dailyChallengeService?.streak ?? 0,
                hasCompletedToday: dailyChallengeService?.hasCompletedToday ?? false,
                onTap: { coordinator.present(.dailyChallenge) }
            )
        }
    }
}

// MARK: - Capital Quiz Section

// MARK: - SRS Review Section

extension HomeScreen {
    var srsReviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Due for Review")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeSRSReviewCard(dueCount: dueReviewCount) {
                coordinator.present(.srsStudy)
            }
        }
    }

    var dueReviewCount: Int {
        let allCards = countryDataService.countries.map {
            FlashcardItem.make(from: $0, type: .countryToCapital)
        }
        return flashcardService.dueCards(from: allCards).count
    }
}

// MARK: - Flag Game Section

extension HomeScreen {
    var flagGameSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Flag Matching")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeFlagGameCard { coordinator.present(.flagGame) }
        }
    }
}

// MARK: - Trivia Section

extension HomeScreen {
    var triviaSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Trivia", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeTriviaCard { coordinator.present(.trivia) }
        }
    }
}

// MARK: - Spelling Bee Section

extension HomeScreen {
    var spellingBeeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Spelling Bee")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeSpellingBeeCard { coordinator.present(.spellingBee) }
        }
    }
}

// MARK: - Learning Path Section

extension HomeScreen {
    var learningPathSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Learning Path")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeLearningPathCard {
                coordinator.present(.learningPath)
            }
        }
    }
}

// MARK: - Map Puzzle Section

extension HomeScreen {
    var mapPuzzleSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Map Puzzle")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeMapPuzzleCard {
                coordinator.push(.mapPuzzle)
            }
        }
    }
}

// MARK: - Landmark Quiz Section

extension HomeScreen {
    var landmarkQuizSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Landmark Quiz")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeLandmarkQuizCard { coordinator.present(.landmarkQuiz) }
        }
    }
}

// MARK: - Feed Section

extension HomeScreen {
    var feedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Feed")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeFeedCard { coordinator.present(.feed) }
        }
    }
}

// MARK: - Continent Stats Section

extension HomeScreen {
    var continentStatsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Continent Statistics")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeContinentStatsCard { coordinator.push(.continentPicker) }
        }
    }
}

// MARK: - Country Compare Section

extension HomeScreen {
    var countryCompareSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Country Comparison")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeCountryCompareCard { coordinator.present(.compare) }
        }
    }
}

// MARK: - Travel Bucket List Section

extension HomeScreen {
    var travelBucketListSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Travel Bucket List")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeTravelBucketListCard { coordinator.present(.travelBucketList) }
        }
    }
}

// MARK: - Ocean Explorer Section

extension HomeScreen {
    var oceanExplorerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Ocean Explorer", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeOceanExplorerCard { coordinator.push(.oceanExplorer) }
        }
    }
}

// MARK: - Language Explorer Section

extension HomeScreen {
    var languageExplorerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Language Explorer")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeLanguageExplorerCard { coordinator.push(.languageExplorer) }
        }
    }
}

// MARK: - Challenge Room Section

extension HomeScreen {
    var challengeRoomSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Challenge Room")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeChallengeRoomCard { coordinator.present(.challengeRoom) }
        }
    }
}

// MARK: - Independence Timeline Section

extension HomeScreen {
    var independenceTimelineSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Independence Timeline")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeIndependenceTimelineCard { coordinator.push(.independenceTimeline) }
        }
    }
}

// MARK: - Economy Explorer Section

extension HomeScreen {
    var economyExplorerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Economy Explorer", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeEconomyExplorerCard { coordinator.push(.economyExplorer) }
        }
    }
}

// MARK: - Geography Features Section

extension HomeScreen {
    var geographyFeaturesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geography Features", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeGeographyFeaturesCard { coordinator.push(.geographyFeatures) }
        }
    }
}

// MARK: - Culture Explorer Section

extension HomeScreen {
    var cultureExplorerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Culture Explorer")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeCultureExplorerCard { coordinator.push(.cultureExplorer) }
        }
    }
}

// MARK: - Landmark Gallery Section

extension HomeScreen {
    var landmarkGallerySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Landmark Gallery")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeLandmarkGalleryCard { coordinator.push(.landmarkGallery) }
        }
    }
}

// MARK: - Quotes Section

extension HomeScreen {
    var quotesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quotes")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeQuotesCard { coordinator.present(.quotes) }
        }
    }
}

// MARK: - Map Coloring Section

extension HomeScreen {
    var mapColoringSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Map Coloring Book", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeMapColoringCard { coordinator.push(.mapColoring) }
        }
    }
}

// MARK: - Country Nicknames Section

extension HomeScreen {
    var countryNicknamesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Country Nicknames", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeCountryNicknamesCard { coordinator.present(.countryNicknames) }
        }
    }
}

// MARK: - Word Search Section

extension HomeScreen {
    var wordSearchSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geography Word Search", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeWordSearchCard { coordinator.present(.wordSearch) }
        }
    }
}

// MARK: - Border Challenge Section

extension HomeScreen {
    var borderChallengeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Border Challenge", isNew: true)
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeBorderChallengeCard { coordinator.present(.borderChallenge) }
        }
    }
}
