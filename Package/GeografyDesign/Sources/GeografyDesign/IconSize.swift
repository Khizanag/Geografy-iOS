import SwiftUI

public extension DesignSystem {
    enum IconSize {
        // Dynamic Type — scales with text when icons appear alongside labels
        public static let small: SwiftUI.Font = .caption2.weight(.bold)
        public static let medium: SwiftUI.Font = .footnote.weight(.semibold)
        public static let large: SwiftUI.Font = .title.weight(.regular)
        // Intentionally fixed — decorative/hero icons that should not scale
        public static let xLarge: SwiftUI.Font = .system(size: 40, weight: .thin)
        public static let xxLarge: SwiftUI.Font = .system(size: 60)
        public static let hero: SwiftUI.Font = .system(size: 80, weight: .thin)
        public static let flag: SwiftUI.Font = .system(size: 200)
    }
}
