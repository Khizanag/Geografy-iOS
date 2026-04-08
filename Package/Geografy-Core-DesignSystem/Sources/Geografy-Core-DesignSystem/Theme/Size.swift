import Foundation

public extension DesignSystem {
    enum Size {
        // MARK: - Flat scale (retained for backward compatibility)
        public static let xxs: CGFloat = 1
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 12
        public static let md: CGFloat = 28
        public static let lg: CGFloat = 40
        public static let xl: CGFloat = 44
        public static let xxl: CGFloat = 48
        public static let xxxl: CGFloat = 60

        // MARK: - Semantic scales (preferred for new code)
        /// Icon frame sizes — for SF Symbols, chevrons, tiny glyphs.
        public enum Icon {
            public static let xs: CGFloat = 12
            public static let sm: CGFloat = 16
            public static let md: CGFloat = 20
            public static let lg: CGFloat = 24
            public static let xl: CGFloat = 28
            public static let xxl: CGFloat = 32
            public static let xxxl: CGFloat = 40
        }

        /// Button height / tap-target sizes — always ≥ 44 for interactive controls (HIG).
        public enum Button {
            public static let compact: CGFloat = 32
            public static let regular: CGFloat = 44
            public static let prominent: CGFloat = 56
        }

        /// Thumbnail sizes for country flags, cover art, avatars-in-rows.
        public enum Thumbnail {
            public static let sm: CGFloat = 56
            public static let md: CGFloat = 72
            public static let lg: CGFloat = 96
            public static let xl: CGFloat = 120
        }

        /// Card heights for home feed, quiz cards, featured grids.
        public enum Card {
            public static let compact: CGFloat = 140
            public static let regular: CGFloat = 180
            public static let featured: CGFloat = 240
        }

        /// Avatar sizes for profile, leaderboard, friend list.
        public enum Avatar {
            public static let sm: CGFloat = 32
            public static let md: CGFloat = 44
            public static let lg: CGFloat = 64
            public static let xl: CGFloat = 96
        }

        /// Decorative dot sizes for badges, notification indicators, status pills.
        public enum Dot {
            public static let sm: CGFloat = 6
            public static let md: CGFloat = 8
            public static let lg: CGFloat = 10
        }

        /// Logo / brand mark sizes for headers and footers.
        public enum Logo {
            public static let sm: CGFloat = 22
            public static let md: CGFloat = 30
            public static let lg: CGFloat = 44
        }

        /// Flag sizes — the product's signature asset. Explicit scale so list / detail / hero all use tokens.
        public enum Flag {
            public static let inline: CGFloat = 24
            public static let row: CGFloat = 32
            public static let compact: CGFloat = 44
            public static let detail: CGFloat = 80
            public static let hero: CGFloat = 160
        }
    }
}
