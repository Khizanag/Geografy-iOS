import SwiftUI
import GeografyDesign
import GeografyCore

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
                CardView {
                    VStack(spacing: 0) {
                        ForEach(Array(funFacts.enumerated()), id: \.offset) { index, fact in
                            FunFactRow(fact: fact)
                            if index < funFacts.count - 1 {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Fun Fact Row
private struct FunFactRow: View {
    let fact: String

    @State private var expanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                expanded.toggle()
            }
        } label: {
            rowContent
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension FunFactRow {
    var rowContent: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            iconCircle
            factText
            Spacer(minLength: 0)
            chevron
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Fun fact: \(fact)")
        .accessibilityHint(expanded ? "Double tap to collapse" : "Double tap to expand")
    }

    var iconCircle: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.warning.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: "lightbulb.fill")
                .font(DesignSystem.Font.footnote)
                .foregroundStyle(DesignSystem.Color.warning)
        }
        .accessibilityHidden(true)
    }

    var factText: some View {
        Text(fact)
            .font(DesignSystem.Font.subheadline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .lineLimit(expanded ? nil : 2)
            .multilineTextAlignment(.leading)
            .animation(.easeInOut(duration: 0.2), value: expanded)
    }

    var chevron: some View {
        Image(systemName: "chevron.down")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .rotationEffect(.degrees(expanded ? 180 : 0))
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: expanded)
            .accessibilityHidden(true)
    }
}
