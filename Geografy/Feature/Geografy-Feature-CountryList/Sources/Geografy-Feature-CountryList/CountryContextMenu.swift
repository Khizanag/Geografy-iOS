import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

struct CountryContextMenu: ViewModifier {
    let country: Country
    let isFavorite: Bool?

    func body(content: Content) -> some View {
        content
            .contextMenu {
                CountryContextMenuItems(country: country, isFavorite: isFavorite)
            }
    }
}

// MARK: - Items
/// Its own view, so the services are read where the menu builds instead of in every row's render.
private struct CountryContextMenuItems: View {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(TravelService.self) private var travelService

    let country: Country
    let isFavorite: Bool?

    var body: some View {
        let isFavorite = self.isFavorite ?? favoritesService.isFavorite(code: country.code)
        Button {
            favoritesService.toggle(code: country.code)
        } label: {
            Label(
                isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: isFavorite ? "heart.slash" : "heart"
            )
        }

        Divider()

        Button {
            travelService.set(status: .visited, for: country.code)
        } label: {
            Label("Mark as Visited", systemImage: "airplane.departure")
        }

        Button {
            travelService.set(status: .wantToVisit, for: country.code)
        } label: {
            Label("Want to Visit", systemImage: "mappin.and.ellipse")
        }

        if travelService.status(for: country.code) != nil {
            Button(role: .destructive) {
                travelService.set(status: nil, for: country.code)
            } label: {
                Label("Clear Travel Status", systemImage: "xmark.circle")
            }
            .tint(DesignSystem.Color.destructive)
        }

        #if targetEnvironment(macCatalyst)
        Divider()

        Button {
            UIPasteboard.general.string = country.name
        } label: {
            Label("Copy Country Name", systemImage: "doc.on.doc")
        }

        Button {
            UIPasteboard.general.string = country.capital
        } label: {
            Label("Copy Capital", systemImage: "doc.on.doc")
        }
        #endif
    }
}

public extension View {
    /// Pass `isFavorite` when the caller already knows it, so the menu needn't look it up.
    func countryContextMenu(_ country: Country, isFavorite: Bool? = nil) -> some View {
        modifier(CountryContextMenu(country: country, isFavorite: isFavorite))
    }
}
