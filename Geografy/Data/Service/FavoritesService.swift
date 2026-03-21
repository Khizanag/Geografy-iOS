import Foundation
import Observation

@Observable
final class FavoritesService {
    private(set) var favoriteCodes: Set<String>

    private let storageKey = "favorite_country_codes"

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        favoriteCodes = Set(stored)
    }

    func toggle(code: String) {
        if favoriteCodes.contains(code) {
            favoriteCodes.remove(code)
        } else {
            favoriteCodes.insert(code)
        }
        persist()
    }

    func isFavorite(code: String) -> Bool {
        favoriteCodes.contains(code)
    }
}

// MARK: - Helpers

private extension FavoritesService {
    func persist() {
        UserDefaults.standard.set(Array(favoriteCodes), forKey: storageKey)
    }
}
