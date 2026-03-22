import SwiftUI

struct FlashcardGuideSheet: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    heroHeader
                    sectionsContent
                    tipsSection
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("How to Study")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleCloseButton()
                }
            }
        }
    }
}

// MARK: - Hero

private extension FlashcardGuideSheet {
    var heroHeader: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignSystem.Color.accent)
            }

            Text("Master Geography\nwith Flashcards")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text("Tap, flip, rate, repeat — build lasting knowledge through spaced repetition.")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Sections

private extension FlashcardGuideSheet {
    var sectionsContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(FlashcardGuide.sections) { section in
                guideCard(section)
            }
        }
    }

    func guideCard(_ section: FlashcardGuideSection) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: section.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
                Text(section.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(section.items, id: \.self) { item in
                    guideItemRow(item)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(
                    DesignSystem.Color.cardBackgroundHighlighted,
                    lineWidth: 1
                )
        )
    }

    func guideItemRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.accent)
                .padding(.top, 2)
            Text(text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }
}

// MARK: - Tips

private extension FlashcardGuideSheet {
    var tipsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Pro Tips", icon: "lightbulb.fill")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(FlashcardGuide.tips) { tip in
                    tipRow(tip)
                }
            }
        }
    }

    func tipRow(_ tip: FlashcardGuideTip) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(tip.emoji)
                .font(DesignSystem.Font.title2)
            Text(tip.text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}
