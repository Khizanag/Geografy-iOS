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

extension HomeScreen {
    var capitalQuizSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Capital City Quiz")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeCapitalQuizCard { coordinator.present(.capitalQuiz) }
        }
    }
}

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

// MARK: - Geo Trivia Section

extension HomeScreen {
    var geoTriviaSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geo Trivia")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeGeoTriviaCard { coordinator.present(.geoTrivia) }
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
                coordinator.push(.learningPath)
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

// MARK: - Geo Feed Section

extension HomeScreen {
    var geoFeedSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geo Feed")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeGeoFeedCard { coordinator.present(.geoFeed) }
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
            SectionHeaderView(title: "Ocean Explorer")
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
            SectionHeaderView(title: "Economy Explorer")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeEconomyExplorerCard { coordinator.push(.economyExplorer) }
        }
    }
}

// MARK: - Geography Features Section

extension HomeScreen {
    var geographyFeaturesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Geography Features")
                .padding(.bottom, DesignSystem.Spacing.xxs)
            HomeGeographyFeaturesCard { coordinator.push(.geographyFeatures) }
        }
    }
}
