import Foundation
import Geografy_Core_DesignSystem
import SwiftUI

/// Pin Drop's colors, and how its ratings, grades, and distances read.
enum PinDropStyle {
    static let gameColor = DesignSystem.Color.orange
    static let pinColor = DesignSystem.Color.error

    static func distance(_ kilometers: Double, locale: Locale) -> String {
        Measurement(value: kilometers.rounded(), unit: UnitLength.kilometers).formatted(
            .measurement(
                width: .abbreviated,
                usage: .asProvided,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
            .locale(locale)
        )
    }

    static func points(_ points: Double, locale: Locale) -> String {
        Int(points.rounded()).formatted(.number.locale(locale))
    }
}

// MARK: - Rating
extension PinDropScore.Rating {
    var title: LocalizedStringKey {
        switch self {
        case .bullseye: "Bullseye"
        case .excellent: "So Close"
        case .good: "Nice Guess"
        case .fair: "Not Bad"
        case .far: "Way Off"
        }
    }

    var systemImage: String {
        switch self {
        case .bullseye: "scope"
        case .excellent: "flame.fill"
        case .good: "hand.thumbsup.fill"
        case .fair: "binoculars.fill"
        case .far: "tortoise.fill"
        }
    }

    var color: Color {
        switch self {
        case .bullseye: DesignSystem.Color.success
        case .excellent: DesignSystem.Color.blue
        case .good: DesignSystem.Color.indigo
        case .fair: DesignSystem.Color.warning
        case .far: DesignSystem.Color.error
        }
    }
}

// MARK: - Grade
extension PinDropGrade {
    var color: Color {
        switch self {
        case .s: DesignSystem.Color.warning
        case .a: DesignSystem.Color.success
        case .b: DesignSystem.Color.blue
        case .c: DesignSystem.Color.indigo
        case .d: DesignSystem.Color.textSecondary
        }
    }

    var message: LocalizedStringKey {
        switch self {
        case .s: "Cartographer level. Flawless."
        case .a: "You know this map by heart."
        case .b: "Solid sense of direction."
        case .c: "Getting there. Play again?"
        case .d: "Every explorer starts somewhere."
        }
    }
}
