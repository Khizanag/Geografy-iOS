import Foundation

public extension DesignSystem {
    /// How strongly a color shows through: the few steps every tint, fill, and dimmed element uses.
    enum Opacity {
        /// A barely-there wash behind content.
        public static let faint: Double = 0.08
        /// An icon badge or chip fill.
        public static let tint: Double = 0.15
        /// A border, a pressed state, or a soft glow.
        public static let soft: Double = 0.3
        /// Half: dimmed or disabled.
        public static let half: Double = 0.5
        /// Secondary content that should still read clearly.
        public static let strong: Double = 0.7
        /// Nearly opaque.
        public static let heavy: Double = 0.85
    }
}
