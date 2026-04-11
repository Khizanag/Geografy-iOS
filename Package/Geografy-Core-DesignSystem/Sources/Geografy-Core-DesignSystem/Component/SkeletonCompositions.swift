import SwiftUI

/// Skeleton for a rectangular home-feed card — hero image block, title line,
/// subtitle line, optional CTA row. Mirrors the visual weight of `HomeFeedCard`.
public struct FeedCardSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SkeletonView(.rectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .frame(height: DesignSystem.Size.Card.regular)

            SkeletonLine(widthFraction: 0.7, height: 18)
            SkeletonLine(widthFraction: 0.4, height: 12)

            HStack(spacing: DesignSystem.Spacing.sm) {
                SkeletonView(.capsule)
                    .frame(width: 72, height: 28)
                SkeletonView(.capsule)
                    .frame(width: 56, height: 28)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(DesignSystem.Color.cardBackground)
        )
    }
}

/// Skeleton for a country-list row — flag thumbnail, country name line, capital line.
public struct ListRowSkeleton: View {
    public init() {}

    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            SkeletonView(.rectangle(cornerRadius: 4))
                .frame(width: DesignSystem.Size.Flag.row, height: DesignSystem.Size.Flag.row * 0.6)

            VStack(alignment: .leading, spacing: 6) {
                SkeletonLine(widthFraction: 0.55, height: 16)
                SkeletonLine(widthFraction: 0.35, height: 12)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
}

/// Skeleton for a country-detail hero — large flag, country name, summary band.
public struct DetailHeroSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            SkeletonView(.rectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                .frame(height: DesignSystem.Size.Flag.hero)

            VStack(spacing: 8) {
                SkeletonLine(widthFraction: 0.6, height: 28)
                SkeletonLine(widthFraction: 0.35, height: 14)
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonView(.rectangle(cornerRadius: DesignSystem.CornerRadius.md))
                        .frame(height: 72)
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
}

/// Skeleton for a profile header — avatar + name + stat ribbon.
public struct ProfileHeaderSkeleton: View {
    public init() {}

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            SkeletonView(.circle)
                .frame(width: DesignSystem.Size.Avatar.xl, height: DesignSystem.Size.Avatar.xl)

            SkeletonLine(widthFraction: 0.45, height: 20)
            SkeletonLine(widthFraction: 0.25, height: 12)

            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 6) {
                        SkeletonLine(widthFraction: 0.7, height: 20)
                        SkeletonLine(widthFraction: 0.5, height: 10)
                    }
                    .padding(DesignSystem.Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                            .fill(DesignSystem.Color.cardBackground)
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
    }
}
