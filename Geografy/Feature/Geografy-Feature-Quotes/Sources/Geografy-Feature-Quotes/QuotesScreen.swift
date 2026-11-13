import Geografy_Core_DesignSystem
import SwiftUI

public struct QuotesScreen: View {
    // MARK: - Init
    public init() {}
    // MARK: - Properties
    @State private var quotesService = QuotesService()
    @State private var selectedCategory: QuoteCategory?

    private var displayedQuotes: [Quote] {
        quotesService.quotes(for: selectedCategory)
    }

    private var quotesOfTheDay: [Quote] {
        quotesService.quotesOfTheDay()
    }

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Quotes")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension QuotesScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.lg) {
                quotesOfTheDaySection
                categoryFilter
                quotesList
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

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
                SelectableChip("All", systemImage: "square.grid.2x2.fill", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(QuoteCategory.allCases, id: \.self) { category in
                    SelectableChip(
                        category.displayName,
                        systemImage: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollClipDisabled()
    }

    var quotesList: some View {
        LazyVStack(spacing: DesignSystem.Spacing.sm) {
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
                .font(DesignSystem.Font.iconMedium)
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
                FlagView(countryCode: code, height: 16, fixedWidth: true)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
            }
            Text("— \(quote.author)")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer()
            IconBadge(quote.category.icon, size: .small)
            favoriteButton(quote)
            shareButton(quote)
        }
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

    @ViewBuilder
    func shareButton(_ quote: Quote) -> some View {
        #if !os(tvOS)
        ShareLink(item: "\"\(quote.text)\"\n— \(quote.author)") {
            Image(systemName: "square.and.arrow.up")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .circle)
        #endif
    }
}
