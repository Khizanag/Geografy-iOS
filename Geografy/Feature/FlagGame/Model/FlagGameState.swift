import Foundation
import Geografy_Core_Common

struct FlagGameState {
    var score: Int = 0
    var lives: Int = 3
    var timeRemaining: Double = 60
    var roundNumber: Int = 0
    var answeredCountries: [Country] = []
    var isFinished: Bool = false

    var isAlive: Bool { lives > 0 }
    var hasTimeLeft: Bool { timeRemaining > 0 }
    var isActive: Bool { isAlive && hasTimeLeft && !isFinished }
}
