import SwiftUI

struct QuotesScreen: View {
    @State private var quotesService = QuotesService()
    @State private var selectedCategory: QuoteCategory?

    private var displayedQuotes: [Quote] {
        quotesService.quotes(for: selectedCategory)
    }

    private var quotesOfTheDay: [Quote] {
        quotesService.quotesOfTheDay()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                quotesOfTheDaySection
                categoryFilter
                quotesList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Quotes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews

private extension QuotesScreen {
    var quotesOfTheDaySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Quotes of the Day", icon: "sun.max.fill")
            ForEach(quotesOfTheDay) { quote in
                quoteCard(quote, isHighlighted: true)
            }
        }
    }

    var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                filterChip(label: "All", icon: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    filterChip(
                        label: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
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

    var quotesList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(displayedQuotes) { quote in
                quoteCard(quote, isHighlighted: false)
            }
        }
    }

    func quoteCard(_ quote: Quote, isHighlighted: Bool) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                quoteTextSection(quote, isHighlighted: isHighlighted)
                quoteFooter(quote)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .buttonStyle(PressButtonStyle())
    }

    func quoteTextSection(_ quote: Quote, isHighlighted: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "quote.opening")
                .font(.system(size: 24))
                .foregroundStyle(
                    isHighlighted
                        ? DesignSystem.Color.accent.opacity(0.6)
                        : DesignSystem.Color.textSecondary.opacity(0.4)
                )
            Text(quote.text)
                .font(DesignSystem.Font.body)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func quoteFooter(_ quote: Quote) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let code = quote.countryCode {
                FlagView(countryCode: code, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
            Text("— \(quote.author)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            categoryChip(quote.category)
            favoriteButton(quote)
            shareButton(quote)
        }
    }

    func categoryChip(_ category: QuoteCategory) -> some View {
        Image(systemName: category.icon)
            .font(.system(size: 12))
            .foregroundStyle(DesignSystem.Color.accent)
            .padding(DesignSystem.Spacing.xs)
            .background(DesignSystem.Color.accent.opacity(0.12), in: Circle())
    }

    func favoriteButton(_ quote: Quote) -> some View {
        Button {
            quotesService.toggleFavorite(id: quote.id)
        } label: {
            Image(systemName: quote.isFavorited ? "heart.fill" : "heart")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(
                    quote.isFavorited ? DesignSystem.Color.error : DesignSystem.Color.textSecondary
                )
                .padding(DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }

    func shareButton(_ quote: Quote) -> some View {
        ShareLink(item: "\"\(quote.text)\"\n— \(quote.author)") {
            Image(systemName: "square.and.arrow.up")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .circle)
    }
}

