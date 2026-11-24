import Foundation

public extension DesignSystem {
    enum CornerRadius {
        /// Small thumbnails and flags inline with text.
        public static let extraSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let extraLarge: CGFloat = 24
        public static let pill: CGFloat = 50
        /// Every card and callout on a page, so their curves match; a panel inside a card takes `nested(inset:)`.
        public static let card: CGFloat = extraLarge

        /// The radius for a panel inset inside a rounded container, so both curves stay parallel.
        public static func nested(in outer: CGFloat = card, inset: CGFloat) -> CGFloat {
            max(outer - inset, 0)
        }
    }
}
