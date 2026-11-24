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

/// A game's guide: pages that swipe sideways, each with an illustration, a title, a short explanation, and steps.
/// Next walks through them and becomes Got It on the last page; the close button leaves at any time.
public struct GuideSheet<Illustration: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    public let title: String
    public let pages: [GuidePage]
    public let color: Color
    public let illustration: (Int) -> Illustration

    @State private var currentPage = 0

    // MARK: - Init
    /// - Parameters:
    ///   - title: The game's name, for the navigation bar.
    ///   - color: The game's color, for the step icons, the current page, and the button.
    public init(
        title: String,
        pages: [GuidePage],
        color: Color = DesignSystem.Color.accent,
        @ViewBuilder illustration: @escaping (Int) -> Illustration
    ) {
        self.title = title
        self.pages = pages
        self.color = color
        self.illustration = illustration
    }

    // MARK: - Body
    public var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageContent(page, index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // The controls keep one height on every page, so the pages never resize as they change.
            .bottomActionBar { controls }
            // Always a sheet, so never above the tab bar, whichever tab opens it.
            .sitsAboveTabBar(false)
            .screenBackground()
            .navigationTitle(title)
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
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
            .padding(.vertical, DesignSystem.Spacing.lg)
            .readableContentWidth()
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    func pageText(_ page: GuidePage) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(page.title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(page.subtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    func stepsSection(_ steps: [GuideStep]) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(steps) { step in
                stepCard(step)
            }
        }
    }

    func stepCard(_ step: GuideStep) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: step.icon)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(color)
                    .frame(width: DesignSystem.Size.Button.regular, height: DesignSystem.Size.Button.regular)
                    .background(color.opacity(DesignSystem.Opacity.tint), in: .circle)
                    .accessibilityHidden(true)
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
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Controls
private extension GuideSheet {
    var controls: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            pageIndicator
            GlassButton(
                isLastPage ? "Got It" : "Next",
                systemImage: isLastPage ? "checkmark" : "arrow.right",
                role: isLastPage ? .primary : .secondary,
                fullWidth: true
            ) {
                advance()
            }
            .contentTransition(.opacity)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: currentPage)
    }

    var pageIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? color : DesignSystem.Color.cardBackgroundHighlighted)
                    .frame(width: index == currentPage ? 20 : 8, height: 8)
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: show(page: currentPage + 1)
            case .decrement: show(page: currentPage - 1)
            @unknown default: break
            }
        }
    }

    var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    func advance() {
        guard !isLastPage else {
            dismiss()
            return
        }
        show(page: currentPage + 1)
    }

    func show(page: Int) {
        guard pages.indices.contains(page) else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            currentPage = page
        }
    }
}
