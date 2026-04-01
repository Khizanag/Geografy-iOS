import Foundation

enum ChallengeMode: String, CaseIterable {
    case passAndPlay = "Pass & Play"
    case splitScreen = "Split Screen"

    var icon: String {
        switch self {
        case .passAndPlay: "hand.point.right.fill"
        case .splitScreen: "rectangle.split.1x2.fill"
        }
    }

    var description: String {
        switch self {
        case .passAndPlay: "Take turns on one device"
        case .splitScreen: "Play simultaneously — screen split in half"
        }
    }
}
