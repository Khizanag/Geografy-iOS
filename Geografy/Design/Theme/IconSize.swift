import SwiftUI

extension DesignSystem {
    enum IconSize {
        // Dynamic Type — scales with text when icons appear alongside labels
        static let small: SwiftUI.Font = .caption2.weight(.bold)
        static let medium: SwiftUI.Font = .footnote.weight(.semibold)
        static let large: SwiftUI.Font = .title.weight(.regular)
        // Intentionally fixed — decorative/hero icons that should not scale
        static let xLarge: SwiftUI.Font = .system(size: 40, weight: .thin)
        static let xxLarge: SwiftUI.Font = .system(size: 60)
        static let hero: SwiftUI.Font = .system(size: 80, weight: .thin)
        static let flag: SwiftUI.Font = .system(size: 200)
    }
}
