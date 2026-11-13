import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Fun Facts Section
extension CountryDetailScreen {
    var funFacts: [String] {
        let curated = CountryFunFacts.data[country.code] ?? []
        let profileFacts = profileService.profile(for: country.code)?.funFacts.map(\.text) ?? []
        return curated + profileFacts.filter { !curated.contains($0) }
    }

    @ViewBuilder
    var funFactsSection: some View {
        if !funFacts.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Fun Facts")

                ForEach(Array(funFacts.enumerated()), id: \.offset) { index, fact in
                    TappableFunFactCard(fact: fact, index: index)
                }
            }
        }
    }
}

// MARK: - Tappable Fun Fact Card
private struct TappableFunFactCard: View {
    let fact: String
    let index: Int

    @State private var showDetail = false

    var body: some View {
        cardButton
            .sheet(isPresented: $showDetail) {
                FunFactDetailSheet(fact: fact, index: index)
            }
    }
}

// MARK: - Card Content
private extension TappableFunFactCard {
    var cardButton: some View {
        Button { showDetail = true } label: {
            CardView {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    numberCircle
                    factPreview
                    Spacer(minLength: 0)
                    RowChevron()
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Fun fact: \(fact)")
    }

    var numberCircle: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.warning.opacity(0.15))
                .frame(width: 36, height: 36)
            Text("\(index + 1)")
                .font(DesignSystem.Font.footnote)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.warning)
        }
        .accessibilityHidden(true)
    }

    var factPreview: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text("Fact #\(index + 1)")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
            Text(fact)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Detail Sheet
private struct FunFactDetailSheet: View {
    let fact: String
    let index: Int

    @State private var contentHeight: CGFloat = 300

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            SheetIconHeader(icon: "lightbulb.fill")
            factText
        }
        .padding(.top, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
        .presentationDetents([.height(contentHeight)])
    }

    var factText: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            EyebrowLabel("Fun Fact #\(index + 1)", color: DesignSystem.Color.accent)
            Text(fact)
                .font(DesignSystem.Font.title3)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }
}
