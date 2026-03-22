import SwiftUI

struct FlashcardScreen: View {
    @Environment(TabCoordinator.self) private var coordinator
    @Environment(FlashcardService.self) private var flashcardService

    @State private var selectedCardType: FlashcardType = .countryToCapital
    @State private var countryDataService = CountryDataService()
    @AppStorage("flashcard_sessionCardCount") private var sessionCardCount = 20
    @State private var blobAnimating = false
    @State private var appeared = false
    @State private var showGuide = false

    var body: some View {
        scrollContent
            .background { ambientBackground }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showGuide = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showGuide) { FlashcardGuideSheet() }
            .task { loadCountries() }
            .onAppear { startAnimations() }
    }
}

// MARK: - Content

private extension FlashcardScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                statsOverview
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .feedSection(appeared: appeared, delay: 0.0)
                cardTypeSection
                    .feedSection(appeared: appeared, delay: 0.08)
                cardCountSection
                    .feedSection(appeared: appeared, delay: 0.12)
                dueForReviewSection
                    .feedSection(appeared: appeared, delay: 0.14)
                deckGridSection
                    .feedSection(appeared: appeared, delay: 0.20)
            }
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Stats Overview

private extension FlashcardScreen {
    var statsOverview: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            overviewStatTile(
                value: "\(flashcardService.reviewedTodayCount())",
                label: "Today",
                icon: "calendar",
                color: DesignSystem.Color.accent
            )
            overviewStatTile(
                value: "\(flashcardService.currentStreak())",
                label: "Streak",
                icon: "flame.fill",
                color: DesignSystem.Color.orange
            )
            overviewStatTile(
                value: "\(dueCardCount)",
                label: "Due",
                icon: "clock.arrow.circlepath",
                color: DesignSystem.Color.purple
            )
        }
    }

    func overviewStatTile(
        value: String,
        label: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Card Type Section

private extension FlashcardScreen {
    var cardTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Card Type")
                .padding(.horizontal, DesignSystem.Spacing.md)

            TypeSelectionGrid(
                items: FlashcardType.allCases.map { $0 },
                selectedIDs: [selectedCardType.id],
                onSelect: { selectedCardType = $0 }
            )
        }
    }

    var cardCountSection: some View {
        HStack {
            Text("Cards per Session")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Picker("Cards", selection: $sessionCardCount) {
                ForEach([5, 10, 15, 20, 30, 50], id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .pickerStyle(.menu)
            .tint(DesignSystem.Color.accent)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Due for Review

private extension FlashcardScreen {
    @ViewBuilder
    var dueForReviewSection: some View {
        if dueCardCount > 0 {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                SectionHeaderView(title: "Due for Review", icon: "clock.arrow.circlepath")
                    .padding(.horizontal, DesignSystem.Spacing.md)
                dueReviewCard
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    var dueReviewCard: some View {
        let deck = FlashcardDeck.makeDueForReviewDeck(
            cardType: selectedCardType
        )
        return Button { startDueReviewSession() } label: {
            FlashcardDeckCard(
                deck: deck,
                cardCount: dueCardCount,
                masteryPercentage: 0,
                dueCount: dueCardCount
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Deck Grid

private extension FlashcardScreen {
    var deckGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Decks")
                .padding(.horizontal, DesignSystem.Spacing.md)
            deckGrid
        }
    }

    var deckGrid: some View {
        let decks = FlashcardDeck.makeContinentDecks(
            cardType: selectedCardType
        )
        return LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: 160),
                    spacing: DesignSystem.Spacing.sm
                ),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(decks) { deck in
                deckButton(for: deck)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func deckButton(for deck: FlashcardDeck) -> some View {
        let items = cardsForDeck(deck)
        let mastery = flashcardService.masteryPercentage(for: items)
        let dueCount = flashcardService.dueCards(from: items).count

        return Button { startSession(for: deck) } label: {
            FlashcardDeckCard(
                deck: deck,
                cardCount: items.count,
                masteryPercentage: mastery,
                dueCount: dueCount
            )
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Background

private extension FlashcardScreen {
    var ambientBackground: some View {
        ZStack {
            DesignSystem.Color.background

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.26),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -200)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.purple.opacity(0.18),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 100)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.indigo.opacity(0.12),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 36)
                .offset(x: -100, y: 400)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Actions

private extension FlashcardScreen {
    func loadCountries() {
        countryDataService.loadCountries()
        flashcardService.loadData()
    }

    func startSession(for deck: FlashcardDeck) {
        let items = cardsForDeck(deck)
        guard !items.isEmpty else { return }
        let shuffled = items.shuffled()
        let sessionCards = Array(shuffled.prefix(sessionCardCount))
        coordinator.presentFullScreen(
            .flashcardSession(deck: deck, cards: sessionCards)
        )
    }

    func startDueReviewSession() {
        let allCards = makeAllCards()
        let dueCards = flashcardService.dueCards(from: allCards)
        guard !dueCards.isEmpty else { return }
        let deck = FlashcardDeck.makeDueForReviewDeck(
            cardType: selectedCardType
        )
        let sessionCards = Array(dueCards.shuffled().prefix(sessionCardCount))
        coordinator.presentFullScreen(
            .flashcardSession(deck: deck, cards: sessionCards)
        )
    }

    func startAnimations() {
        withAnimation(
            .easeInOut(duration: 6).repeatForever(autoreverses: true)
        ) {
            blobAnimating = true
        }
        withAnimation(.easeOut(duration: 0.7)) {
            appeared = true
        }
    }
}

// MARK: - Helpers

private extension FlashcardScreen {
    func cardsForDeck(_ deck: FlashcardDeck) -> [FlashcardItem] {
        let countries = filteredCountries(
            for: deck.continentFilter
        )
        return countries
            .map { country in
                FlashcardItem.make(from: country, type: selectedCardType)
            }
    }

    func filteredCountries(
        for continent: Country.Continent?
    ) -> [Country] {
        guard let continent else {
            return countryDataService.countries
        }
        return countryDataService.countries.filter {
            $0.continent == continent
        }
    }

    func makeAllCards() -> [FlashcardItem] {
        countryDataService.countries
            .map { country in
                FlashcardItem.make(from: country, type: selectedCardType)
            }
    }

    var dueCardCount: Int {
        flashcardService.dueCards(from: makeAllCards()).count
    }
}

// MARK: - Feed Section Modifier

private extension View {
    func feedSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                .easeOut(duration: 0.5).delay(delay),
                value: appeared
            )
    }
}

