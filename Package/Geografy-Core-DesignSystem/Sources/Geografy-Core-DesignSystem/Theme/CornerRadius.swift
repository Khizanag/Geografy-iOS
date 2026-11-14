import Foundation

public extension DesignSystem {
    enum CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let extraLarge: CGFloat = 24
        public static let pill: CGFloat = 50

        /// The radius for a panel inset inside a rounded container, so both curves stay parallel.
        public static func nested(in outer: CGFloat = extraLarge, inset: CGFloat) -> CGFloat {
            max(outer - inset, 0)
        }
    }
}
