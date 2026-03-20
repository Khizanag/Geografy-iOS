import SwiftUI

extension DesignSystem {
    enum IconSize {
        static let small: SwiftUI.Font = .system(size: 12, weight: .bold)
        static let medium: SwiftUI.Font = .system(size: 14, weight: .semibold)
        static let large: SwiftUI.Font = .system(size: 28)
        static let xLarge: SwiftUI.Font = .system(size: 40, weight: .thin)
        static let xxLarge: SwiftUI.Font = .system(size: 60)
        static let hero: SwiftUI.Font = .system(size: 80, weight: .thin)
        static let flag: SwiftUI.Font = .system(size: 200)
    }
}
