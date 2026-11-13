import Geografy_Core_DesignSystem
import SwiftUI

/// The amount to convert and, as the hero, what it comes to: each in its side's color, with the rate and its age.
struct CurrencyConversionCard: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var amountText: String
    let from: CurrencyEntry
    let to: CurrencyEntry
    let rate: Double?
    let status: CurrencyRateStatus

    @FocusState private var isAmountFocused: Bool

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                amountSection
                Divider()
                resultSection
                rateSection
            }
            .padding(DesignSystem.Spacing.md)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isAmountFocused = false }
            }
        }
    }
}

// MARK: - Amount
private extension CurrencyConversionCard {
    var amountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            sideLabel("Amount", side: .left)
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                TextField("0", text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(DesignSystem.Font.roundedHeadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .tint(PairSide.left.color)
                    .focused($isAmountFocused)
                    .accessibilityLabel("Amount in \(from.name)")
                codeLabel(from.code, side: .left)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isAmountFocused = true }
    }
}

// MARK: - Result
private extension CurrencyConversionCard {
    var resultSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            sideLabel("Converted", side: .right)
            resultValue
        }
    }

    @ViewBuilder
    var resultValue: some View {
        if let converted {
            let formatted = CurrencyAmountFormatter.string(for: converted)
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                Text(formatted)
                    .font(DesignSystem.Font.roundedHeadline)
                    .foregroundStyle(PairSide.right.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText(value: converted))
                    .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: converted)
                codeLabel(to.code, side: .right)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Converted")
            .accessibilityValue("\(formatted) \(to.name)")
        } else if status == .loading {
            ProgressView()
                .frame(minHeight: DesignSystem.Size.xl)
                .accessibilityLabel("Loading rates")
        } else {
            Label("No rates yet. Connect to the internet once to download them.", systemImage: "wifi.slash")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var converted: Double? {
        guard let rate else { return nil }
        return (CurrencyAmountFormatter.amount(from: amountText) ?? 0) * rate
    }
}

// MARK: - Rate
private extension CurrencyConversionCard {
    @ViewBuilder
    var rateSection: some View {
        if let rate, rate > 0 {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                VStack(alignment: .leading, spacing: 2) {
                    rateLine(from: from.code, to: to.code, rate: rate)
                    rateLine(from: to.code, to: from.code, rate: 1 / rate)
                }
                statusPill
            }
        }
    }

    func rateLine(from fromCode: String, to toCode: String, rate: Double) -> some View {
        Text(verbatim: "1 \(fromCode) = \(CurrencyAmountFormatter.string(for: rate)) \(toCode)")
            .font(DesignSystem.Font.footnote.monospacedDigit())
            .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    @ViewBuilder
    var statusPill: some View {
        switch status {
        case .live(let updated?):
            InfoPill("Updated \(relative(updated))", systemImage: "clock")
        case .cached(let updated):
            InfoPill(
                updated.map { "Offline · rates from \(relative($0))" } ?? "Offline · cached rates",
                systemImage: "wifi.slash"
            )
        case .live(nil), .loading, .unavailable:
            EmptyView()
        }
    }

    func relative(_ date: Date) -> String {
        date.formatted(.relative(presentation: .named))
    }
}

// MARK: - Helpers
private extension CurrencyConversionCard {
    func sideLabel(_ title: String, side: PairSide) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Circle()
                .fill(side.color)
                .frame(width: DesignSystem.Spacing.xs, height: DesignSystem.Spacing.xs)
                .accessibilityHidden(true)
            Text(title)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityHidden(true)
    }

    func codeLabel(_ code: String, side: PairSide) -> some View {
        Text(code)
            .font(DesignSystem.Font.title3)
            .foregroundStyle(side.color)
            .accessibilityHidden(true)
    }
}
