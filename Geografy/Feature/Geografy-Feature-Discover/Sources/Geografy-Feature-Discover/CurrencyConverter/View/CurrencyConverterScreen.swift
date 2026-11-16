import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct CurrencyConverterScreen: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(CurrencyService.self) private var currencyService
    @Environment(HapticsService.self) private var hapticsService

    private let preselectedCurrencyCode: String?

    @State private var currencies: [CurrencyEntry] = []
    @State private var fromCurrency: CurrencyEntry?
    @State private var toCurrency: CurrencyEntry?
    @State private var amountText = "1"
    @State private var pickingSide: PairSide?
    @State private var recentPairs: [CurrencyPair] = []
    @State private var hasAppliedPreselection = false

    // MARK: - Init
    public init(preselectedCurrencyCode: String? = nil) {
        self.preselectedCurrencyCode = preselectedCurrencyCode
    }

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Currency Converter")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: fromCurrency?.code) { await fetchRates() }
            .onAppear(perform: loadRecents)
            .onChange(of: countryDataService.countries.count, initial: true) { loadCurrencies() }
            .sheet(item: $pickingSide) { side in
                CoordinatedNavigationStack(showCloseButton: true) {
                    picker(for: side)
                }
            }
    }
}

// MARK: - Subviews
private extension CurrencyConverterScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                pairHeader
                content
                if !recentEntryPairs.isEmpty {
                    recentSection
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.xs)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: selectionID)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    var pairHeader: some View {
        PairSelector(
            left: fromCurrency.map(slotItem),
            right: toCurrency.map(slotItem),
            roles: (left: "From", right: "To"),
            placeholder: "Choose a currency",
            centerLabel: "TO",
            onPick: { pickingSide = $0 },
            onClear: { setCurrency(nil, on: $0) },
            onSwap: swapCurrencies
        )
    }

    func slotItem(_ currency: CurrencyEntry) -> PairSlotItem {
        PairSlotItem(flagCode: currency.flagCode, title: currency.code, subtitle: currency.name)
    }

    @ViewBuilder
    var content: some View {
        if let fromCurrency, let toCurrency {
            let rate = currencyService.convert(amount: 1, from: fromCurrency.code, to: toCurrency.code)
            CurrencyConversionCard(
                amountText: $amountText,
                from: fromCurrency,
                to: toCurrency,
                rate: rate,
                status: rateStatus(hasRate: rate != nil)
            )
            if let rate {
                CurrencyQuickAmountsView(from: fromCurrency, to: toCurrency, rate: rate) { amount in
                    hapticsService.selection()
                    amountText = CurrencyAmountFormatter.inputString(for: amount)
                }
            }
        } else {
            CurrencyStartView(
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                currencies: currencies,
                onChoose: { currency, side in
                    hapticsService.selection()
                    setCurrency(currency, on: side)
                },
                onChoosePair: open,
                onShuffle: shuffle
            )
        }
    }

    var recentSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(
                title: "Recent",
                action: SectionHeaderAction(
                    "Clear",
                    accessibilityLabel: "Clear recent conversions",
                    perform: clearRecents
                )
            )
            CurrencyPairList(pairs: recentEntryPairs, onSelect: open)
        }
    }

    func picker(for side: PairSide) -> some View {
        let otherCode = currency(on: side.other)?.code
        return CurrencyPickerSheet(
            title: side == .left ? "Convert From" : "Convert To",
            currencies: currencies.filter { $0.code != otherCode },
            selectedCode: currency(on: side)?.code,
            side: side
        ) { selected in
            setCurrency(selected, on: side)
        }
    }
}

// MARK: - Actions
private extension CurrencyConverterScreen {
    func loadCurrencies() {
        currencies = CurrencyCatalog.entries(from: countryDataService.countries)
        guard !hasAppliedPreselection, !currencies.isEmpty else { return }
        hasAppliedPreselection = true
        if let preselectedCurrencyCode, fromCurrency == nil {
            fromCurrency = currencies.first { $0.code == preselectedCurrencyCode }
        }
    }

    func fetchRates() async {
        guard let code = fromCurrency?.code else { return }
        await currencyService.fetchRates(for: code)
    }

    func setCurrency(_ currency: CurrencyEntry?, on side: PairSide) {
        switch side {
        case .left: fromCurrency = currency
        case .right: toCurrency = currency
        }
        saveIfBothSelected()
    }

    func open(_ pair: CurrencyEntryPair) {
        hapticsService.selection()
        fromCurrency = pair.from
        toCurrency = pair.to
        saveIfBothSelected()
    }

    func swapCurrencies() {
        hapticsService.impact(.light)
        (fromCurrency, toCurrency) = (toCurrency, fromCurrency)
        saveIfBothSelected()
    }

    /// Fills whichever slots are empty with random currencies.
    func shuffle() {
        hapticsService.impact(.light)
        let from = fromCurrency ?? currencies.filter { $0.code != toCurrency?.code }.randomElement()
        let to = toCurrency ?? currencies.filter { $0.code != from?.code }.randomElement()
        fromCurrency = from
        toCurrency = to
        saveIfBothSelected()
    }

    func clearRecents() {
        recentPairs = []
        CurrencyRecents.save(recentPairs)
    }
}

// MARK: - Recents
private extension CurrencyConverterScreen {
    func loadRecents() {
        recentPairs = CurrencyRecents.load()
    }

    func saveIfBothSelected() {
        guard let fromCurrency, let toCurrency else { return }
        let pair = CurrencyPair(fromCode: fromCurrency.code, toCode: toCurrency.code)
        recentPairs = CurrencyRecents.inserting(pair, into: recentPairs)
        CurrencyRecents.save(recentPairs)
    }
}

// MARK: - Helpers
private extension CurrencyConverterScreen {
    var recentEntryPairs: [CurrencyEntryPair] {
        CurrencyEntryPair.resolve(recentPairs, in: currencies)
    }

    /// Changes whenever the screen's layout does, so one animation covers every transition.
    var selectionID: String {
        "\(fromCurrency?.code ?? "")-\(toCurrency?.code ?? "")-\(recentPairs.count)"
    }

    func currency(on side: PairSide) -> CurrencyEntry? {
        switch side {
        case .left: fromCurrency
        case .right: toCurrency
        }
    }

    func rateStatus(hasRate: Bool) -> CurrencyRateStatus {
        CurrencyRateStatus(
            hasRate: hasRate,
            isLoading: currencyService.isLoading,
            hasError: currencyService.fetchError != nil,
            lastUpdated: currencyService.lastUpdated
        )
    }
}
