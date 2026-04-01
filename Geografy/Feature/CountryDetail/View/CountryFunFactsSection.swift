import GeografyCore
import GeografyDesign
import SwiftUI

// MARK: - Fun Facts Section
extension CountryDetailScreen {
    var funFacts: [String] {
        CountryFunFacts.data[country.code] ?? []
    }

    @ViewBuilder
    var funFactsSection: some View {
        if !funFacts.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                sectionHeader("Fun Facts")

                ForEach(Array(funFacts.enumerated()), id: \.offset) { index, fact in
                    FunFactCard(fact: fact, index: index)
                }
            }
        }
    }
}

// MARK: - Fun Fact Card
private struct FunFactCard: View {
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
private extension FunFactCard {
    var cardButton: some View {
        Button { showDetail = true } label: {
            CardView {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    iconCircle
                    factText
                    Spacer(minLength: 0)
                    chevron
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("Fun fact: \(fact)")
    }

    var iconCircle: some View {
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

    var factText: some View {
        Text(fact)
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }

    var chevron: some View {
        Image(systemName: "chevron.right")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .accessibilityHidden(true)
    }
}

// MARK: - Detail Sheet
private struct FunFactDetailSheet: View {
    let fact: String
    let index: Int

    var body: some View {
        sheetContent
            .navigationTitle("Fun Fact")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium])
    }
}

// MARK: - Sheet Content
private extension FunFactDetailSheet {
    var sheetContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerIcon

                Text(fact)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
        .background(DesignSystem.Color.background)
    }

    var headerIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.warning.opacity(0.15))
                .frame(width: 56, height: 56)
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.warning)
        }
    }
}
