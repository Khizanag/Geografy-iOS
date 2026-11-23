import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// How much space Geografy takes on this device, what that space holds, and a way to free the part that downloads again.
public struct StorageScreen: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale

    @State private var usage: StorageUsage?
    @State private var isClearing = false
    @State private var showClearConfirmation = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                summaryCard
                categoriesCard
                clearCacheSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
        .screenBackground()
        .navigationTitle(String(localized: "Storage", in: locale))
        #if !os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task { await refresh() }
        .haptic(trigger: isClearing) { wasClearing, clearing in
            wasClearing && !clearing ? .success : nil
        }
        .confirmationDialog("Clear Cache?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear Cache", role: .destructive) {
                Task { await clearCache() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Statistics and exchange rates download again the next time you're online.")
        }
    }
}

// MARK: - Categories
private extension StorageScreen {
    struct Category: Identifiable {
        let id: String
        let icon: String
        let color: Color
        let title: LocalizedStringKey
        let detail: LocalizedStringKey
        let bytes: Int64
    }

    var categories: [Category] {
        let usage = usage ?? .empty
        return [
            Category(
                id: "app",
                icon: "app.fill",
                color: DesignSystem.Color.blue,
                title: "App",
                detail: "Geografy itself, with its maps and flags",
                bytes: usage.app
            ),
            Category(
                id: "userData",
                icon: "person.crop.circle.fill",
                color: DesignSystem.Color.indigo,
                title: "Your data",
                detail: "Progress, favorites, travel journal, and settings",
                bytes: usage.userData
            ),
            Category(
                id: "cache",
                icon: "arrow.down.circle.fill",
                color: DesignSystem.Color.orange,
                title: "Cache",
                detail: "Downloaded statistics and exchange rates",
                bytes: usage.cache
            ),
        ]
    }

    func formatted(_ bytes: Int64) -> String {
        bytes.formatted(.byteCount(style: .file).locale(locale))
    }
}

// MARK: - Subviews
private extension StorageScreen {
    var summaryCard: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(verbatim: formatted(usage?.total ?? 0))
                        .font(DesignSystem.Font.title)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .contentTransition(.numericText())
                    Text("Used on this device")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                StorageBar(segments: categories.map { ($0.color, $0.bytes) })
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .redacted(reason: usage == nil ? .placeholder : [])
        .accessibilityElement(children: .combine)
    }

    var categoriesCard: some View {
        let dividerInset = RowListCardLayout.iconBadgeWidth + DesignSystem.Spacing.md * 2
        return RowListCard(categories, dividerInset: dividerInset) { category in
            HStack(spacing: DesignSystem.Spacing.md) {
                IconBadge(category.icon, color: category.color, size: .small)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text(category.title)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(category.detail)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer(minLength: DesignSystem.Spacing.xs)
                Text(verbatim: formatted(category.bytes))
                    .font(DesignSystem.Font.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .redacted(reason: usage == nil ? .placeholder : [])
            }
            .rowListCardRow()
            .accessibilityElement(children: .combine)
        }
    }

    var clearCacheSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Button {
                showClearConfirmation = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if isClearing {
                        ProgressView()
                    }
                    Text("Clear Cache")
                        .font(DesignSystem.Font.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.glass)
            .tint(DesignSystem.Color.destructive)
            .disabled(isClearing || (usage?.cache ?? 0) == 0)

            Text("Your progress and travel journal are kept.")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
        }
    }
}

// MARK: - Actions
private extension StorageScreen {
    func refresh() async {
        let latest = await StorageUsage.read()
        withAnimation(.easeOut(duration: 0.3)) {
            usage = latest
        }
    }

    func clearCache() async {
        isClearing = true
        await StorageUsage.clearCache()
        await refresh()
        isClearing = false
    }
}

// MARK: - Storage Bar
/// One capsule split into the share each part takes, in that part's color.
private struct StorageBar: View {
    let segments: [(color: Color, bytes: Int64)]

    var body: some View {
        GeometryReader { geometry in
            let total = max(segments.reduce(0) { $0 + $1.bytes }, 1)
            HStack(spacing: DesignSystem.Spacing.xxxs) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    if segment.bytes > 0 {
                        segment.color
                            .frame(width: max(geometry.size.width * CGFloat(segment.bytes) / CGFloat(total) - 2, 2))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .clipShape(Capsule())
        }
        .frame(height: DesignSystem.Spacing.sm)
        .accessibilityHidden(true)
    }
}
