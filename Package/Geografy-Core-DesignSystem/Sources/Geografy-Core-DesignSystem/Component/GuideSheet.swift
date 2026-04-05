import SwiftUI

public struct GuidePage: Identifiable, Sendable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let steps: [GuideStep]

    public init(title: String, subtitle: String, steps: [GuideStep]) {
        self.title = title
        self.subtitle = subtitle
        self.steps = steps
    }
}

public struct GuideStep: Identifiable, Sendable {
    public let id = UUID()
    public let icon: String
    public let title: String
    public let description: String

    public init(icon: String, title: String, description: String) {
        self.icon = icon
        self.title = title
        self.description = description
    }
}

public struct GuideSheet<Illustration: View>: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss

    public let pages: [GuidePage]
    public let illustration: (Int) -> Illustration

    @State private var currentPage = 0

    // MARK: - Init
    public init(
        pages: [GuidePage],
        @ViewBuilder illustration: @escaping (Int) -> Illustration
    ) {
        self.pages = pages
        self.illustration = illustration
    }

    // MARK: - Body
    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageContent(page, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            pageIndicatorAndButton
        }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Page Content
private extension GuideSheet {
    func pageContent(_ page: GuidePage, index: Int) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                illustration(index)
                pageText(page)
                if !page.steps.isEmpty {
                    stepsSection(page.steps)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }

    func pageText(_ page: GuidePage) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(page.title)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
            Text(page.subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func stepsSection(_ steps: [GuideStep]) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(steps) { step in
                stepCard(step)
            }
        }
    }

    func stepCard(_ step: GuideStep) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: step.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(step.title)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(step.description)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - Page Indicator
private extension GuideSheet {
    var pageIndicatorAndButton: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentPage
                                ? DesignSystem.Color.accent
                                : DesignSystem.Color.cardBackgroundHighlighted
                        )
                        .frame(width: index == currentPage ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }

            if currentPage == pages.count - 1 {
                GlassButton("Got it!", systemImage: "checkmark", fullWidth: true) {
                    dismiss()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .animation(.easeInOut(duration: 0.25), value: currentPage)
    }
}
