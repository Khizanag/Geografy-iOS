#if !os(tvOS)
import Foundation

enum LocalMatchState: Equatable {
    case idle
    case advertising
    case browsing
    case lobby
    case countdown(remaining: Int)
    case playing
    case finished
    case disconnected
}
#endif
