import Foundation
import Geografy_Core_Common

public struct FlagGameState {
    public var score: Int = 0
    public var lives: Int = 3
    public var timeRemaining: Double = 60
    public var roundNumber: Int = 0
    public var answeredCountries: [Country] = []
    public var isFinished: Bool = false

    public var isAlive: Bool { lives > 0 }
    public var hasTimeLeft: Bool { timeRemaining > 0 }
    public var isActive: Bool { isAlive && hasTimeLeft && !isFinished }
}
