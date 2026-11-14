import Observation

// Kept out of the screen's own state so scrolling past the flag redraws only the views that read it.
@MainActor
@Observable
final class CountryDetailScrollState {
    var isFlagScrolledUp = false
}
