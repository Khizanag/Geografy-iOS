import Geografy_Core_DesignSystem
import Geografy_Feature_Quotes
import SwiftUI

struct QuotesScreen: View {
    @State private var service = QuotesService()
    @State private var selectedCategory: QuoteCategory?

    private var filteredQuotes: [Quote] {
        guard let selectedCategory else { return service.quotes }
        return service.quotes.filter { $0.category == selectedCategory }
    }

    var body: some View {
        List {
            Section {
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as QuoteCategory?)
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        Label(category.displayName, systemImage: category.icon)
                            .tag(category as QuoteCategory?)
                    }
                }
            }

            Section {
                ForEach(filteredQuotes) { quote in
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("\u{201C}\(quote.text)\u{201D}")
                            .font(DesignSystem.Font.system(size: 22))
                            .italic()

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            Text("\u{2014} \(quote.author)")
                                .font(DesignSystem.Font.system(size: 22, weight: .semibold))
                                .foregroundStyle(.secondary)

                            if let code = quote.countryCode {
                                FlagView(countryCode: code, height: 20)
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xs)
                }
            }
        }
        .navigationTitle("Quotes")
    }
}
