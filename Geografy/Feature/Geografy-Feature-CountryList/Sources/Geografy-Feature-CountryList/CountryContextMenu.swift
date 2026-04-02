import Geografy_Core_Common
import Geografy_Core_Service
import SwiftUI

struct CountryContextMenu: ViewModifier {
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(TravelService.self) private var travelService

    let country: Country

    func body(content: Content) -> some View {
        content
            // swiftlint:disable:next closure_body_length
            .contextMenu {
                Button {
                    favoritesService.toggle(code: country.code)
                } label: {
                    Label(
                        favoritesService.isFavorite(code: country.code)
                            ? "Remove from Favorites"
                            : "Add to Favorites",
                        systemImage: favoritesService.isFavorite(code: country.code)
                            ? "heart.slash"
                            : "heart"
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
}

public extension View {
    func countryContextMenu(_ country: Country) -> some View {
        modifier(CountryContextMenu(country: country))
    }
}
