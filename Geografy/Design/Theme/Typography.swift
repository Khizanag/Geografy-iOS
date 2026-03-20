import SwiftUI

extension DesignSystem {
    enum Font {
        static let largeTitle: SwiftUI.Font = .system(size: 34, weight: .bold)
        static let title: SwiftUI.Font = .system(size: 28, weight: .bold)
        static let title2: SwiftUI.Font = .system(size: 22, weight: .semibold)
        static let headline: SwiftUI.Font = .system(size: 17, weight: .semibold)
        static let body: SwiftUI.Font = .system(size: 17, weight: .regular)
        static let callout: SwiftUI.Font = .system(size: 16, weight: .regular)
        static let subheadline: SwiftUI.Font = .system(size: 15, weight: .regular)
        static let footnote: SwiftUI.Font = .system(size: 13, weight: .regular)
        static let caption: SwiftUI.Font = .system(size: 12, weight: .regular)
        static let caption2: SwiftUI.Font = .system(size: 11, weight: .regular)
    }
}
