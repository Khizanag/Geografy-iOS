#if !os(tvOS)
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CurrencyConverterScreen: View {
    public init() {}
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(CurrencyService.self) private var currencyService
    @Environment(HapticsService.self) private var hapticsService

    public let preselectedCurrencyCode: String?

    @State private var fromCurrency: CurrencyEntry?
    @State private var toCurrency: CurrencyEntry?
    @State private var amountText = "1"
    @State private var showFromPicker = false
    @State private var showToPicker = false
    @State private var blobAnimating = false

    public init(preselectedCurrencyCode: String? = nil) {
        self.preselectedCurrencyCode = preselectedCurrencyCode
    }

    public var body: some View {
        extractedContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Currency Converter")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                setupDefaults()
                if let from = fromCurrency {
                    await currencyService.fetchRates(for: from.code)
                }
            }
            .onAppear { blobAnimating = true }
            .sheet(isPresented: $showFromPicker) {
                CurrencyPickerSheet(title: "From Currency", currencies: allCurrencies) { entry in
                    hapticsService.selection()
                    fromCurrency = entry
                    Task { await currencyService.fetchRates(for: entry.code) }
                }
            }
            .sheet(isPresented: $showToPicker) {
                CurrencyPickerSheet(title: "To Currency", currencies: allCurrencies) { entry in
                    hapticsService.selection()
                    toCurrency = entry
                }
            }
    }
}

// MARK: - Subviews
private extension CurrencyConverterScreen {
    var extractedContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                quickChipsSection
                converterCard
                if convertedAmount != nil {
                    resultSection
                }
                if let updated = currencyService.lastUpdated {
                    updatedFooter(date: updated)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var quickChipsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("Quick select")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(quickCurrencies, id: \.code) { entry in
                        quickChip(for: entry)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    func quickChip(for entry: CurrencyEntry) -> some View {
        let isSelected = fromCurrency?.code == entry.code
        return Button {
            hapticsService.impact(.light)
            fromCurrency = entry
            Task { await currencyService.fetchRates(for: entry.code) }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                FlagView(countryCode: entry.countryCode, height: 16)
                Text(entry.code)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isSelected
                            ? DesignSystem.Color.onAccent
                            : DesignSystem.Color.textPrimary
                    )
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs + 2)
            .background(
                isSelected
                    ? DesignSystem.Color.accent
                    : DesignSystem.Color.cardBackground,
                in: Capsule()
            )
            .overlay(
                Capsule().strokeBorder(
                    isSelected
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textTertiary.opacity(0.3),
                    lineWidth: 1
                )
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var converterCard: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                fromPickerRow
                amountRow
                Divider()
                    .padding(.horizontal, -DesignSystem.Spacing.md)
                swapRow
                Divider()
                    .padding(.horizontal, -DesignSystem.Spacing.md)
                toPickerRow
            }
            .padding(DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    var fromPickerRow: some View {
        currencyPickerButton(
            entry: fromCurrency,
            placeholder: "Select base currency",
            label: "From",
            color: DesignSystem.Color.accent
        ) { showFromPicker = true }
    }

    var toPickerRow: some View {
        currencyPickerButton(
            entry: toCurrency,
            placeholder: "Select target currency",
            label: "To",
            color: DesignSystem.Color.blue
        ) { showToPicker = true }
    }

    func currencyPickerButton(
        entry: CurrencyEntry?,
        placeholder: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(label)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .frame(width: 50, alignment: .leading)

                if let entry {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        FlagView(countryCode: entry.countryCode, height: 22, fixedWidth: true)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.code)
                                .font(DesignSystem.Font.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Text(entry.name)
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textSecondary)
                                .lineLimit(1)
                        }
                    }
                } else {
                    Text(placeholder)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(color.opacity(0.6))
                    .accessibilityHidden(true)
            }
            .padding(DesignSystem.Spacing.sm)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var amountRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text("Amount")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .frame(width: 50, alignment: .leading)

            TextField("0", text: $amountText)
                .keyboardType(.decimalPad)
                .font(DesignSystem.Font.roundedSubheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.leading)

            if let code = fromCurrency?.code {
                Text(code)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }

    var swapRow: some View {
        HStack {
            Spacer()
            Button {
                hapticsService.impact(.light)
                let previous = fromCurrency
                fromCurrency = toCurrency
                toCurrency = previous
                if let from = fromCurrency {
                    Task { await currencyService.fetchRates(for: from.code) }
                }
            } label: {
                Label("Swap", systemImage: "arrow.up.arrow.down.circle.fill")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .buttonStyle(PressButtonStyle())
            Spacer()
        }
    }

    var resultSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if currencyService.isLoading {
                    ProgressView()
                        .tint(DesignSystem.Color.accent)
                } else if let converted = convertedAmount, let toEntry = toCurrency {
                    resultContent(converted: converted, toEntry: toEntry)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.lg)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }

    func resultContent(converted: Double, toEntry: CurrencyEntry) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("Result")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .textCase(.uppercase)
                .accessibilityAddTraits(.isHeader)

            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                Text(formatAmount(converted))
                    .font(DesignSystem.Font.roundedXL)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4), value: converted)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text(toEntry.code)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(formatAmount(converted)) \(toEntry.code)")

            if let amount = Double(amountText), let fromEntry = fromCurrency {
                Text(
                    "\(formatAmount(amount)) \(fromEntry.code) = \(formatAmount(converted)) \(toEntry.code)"
                )
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    func updatedFooter(date: Date) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "clock")
                .font(DesignSystem.Font.caption2)
                .accessibilityHidden(true)
            Text("Rates updated \(date.formatted(.relative(presentation: .named)))")
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.textTertiary)
        .accessibilityElement(children: .combine)
    }

    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.success.opacity(0.18), .clear],
                        center: .center, startRadius: 0, endRadius: 200
                    )
                )
                .frame(width: 400, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -60)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.blue.opacity(0.14), .clear],
                        center: .center, startRadius: 0, endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 380)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true),
            value: blobAnimating
        )
    }
}

// MARK: - Actions
private extension CurrencyConverterScreen {
    func setupDefaults() {
        let currencies = allCurrencies
        guard !currencies.isEmpty else { return }

        if let preselected = preselectedCurrencyCode,
           let match = currencies.first(where: { $0.code == preselected }) {
            fromCurrency = match
        } else {
            fromCurrency = currencies.first(where: { $0.code == "USD" }) ?? currencies.first
        }

        toCurrency = currencies.first(where: { $0.code == "EUR" })
            ?? currencies.first(where: { $0.code != fromCurrency?.code })
    }
}

// MARK: - Helpers
private extension CurrencyConverterScreen {
    var allCurrencies: [CurrencyEntry] {
        var seen = Set<String>()
        return countryDataService.countries.compactMap { country in
            let code = country.currency.code
            guard !seen.contains(code) else { return nil }
            seen.insert(code)
            return CurrencyEntry(
                code: code,
                name: country.currency.name,
                countryCode: country.code
            )
        }
        .sorted { $0.code < $1.code }
    }

    var quickCurrencies: [CurrencyEntry] {
        let priorityCodes = ["USD", "EUR", "GBP", "JPY", "CHF", "CNY", "AUD", "CAD"]
        let map = Dictionary(uniqueKeysWithValues: allCurrencies.map { ($0.code, $0) })
        return priorityCodes.compactMap { map[$0] }
    }

    var convertedAmount: Double? {
        guard
            let amount = Double(amountText),
            let fromEntry = fromCurrency,
            let toEntry = toCurrency,
            !currencyService.rates.isEmpty
        else { return nil }
        return currencyService.convert(amount: amount, from: fromEntry.code, to: toEntry.code)
    }

    func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = value < 1 ? 4 : 2
        formatter.maximumFractionDigits = value < 1 ? 4 : 2
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Currency Entry
public struct CurrencyEntry: Identifiable, Hashable {
    public let code: String
    public let name: String
    public let countryCode: String

    public var id: String { code }
}

// MARK: - Currency Picker Sheet
private struct CurrencyPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    public let title: String
    public let currencies: [CurrencyEntry]
    public let onSelect: (CurrencyEntry) -> Void

    @State private var searchText = ""

    public var body: some View {
        extractedContent
            .searchable(text: $searchText, prompt: "Search currency or country…")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
    }
}

// MARK: - Subviews
private extension CurrencyPickerSheet {
    var extractedContent: some View {
        List(filteredCurrencies) { entry in
            Button {
                onSelect(entry)
                dismiss()
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(countryCode: entry.countryCode, height: 24, fixedWidth: true)
                        .frame(width: 36, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.code)
                            .font(DesignSystem.Font.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(entry.name)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Toolbar
private extension CurrencyPickerSheet {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
                .tint(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Helpers
private extension CurrencyPickerSheet {
    var filteredCurrencies: [CurrencyEntry] {
        guard !searchText.isEmpty else { return currencies }
        let query = searchText.lowercased()
        return currencies.filter {
            $0.code.lowercased().contains(query) || $0.name.lowercased().contains(query)
        }
    }
}
#endif
