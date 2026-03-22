import SwiftUI

struct CoordinatedNavigationStack<Root: View>: View {
    @Bindable var coordinator: TabCoordinator
    @ViewBuilder var root: () -> Root

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .navigationDestination(for: Screen.self) { screen in
                    ScreenFactory.view(for: screen)
                }
                .navigationDestination(for: Country.self) { country in
                    CountryDetailScreen(country: country)
                }
        }
        .sheet(item: $coordinator.activeSheet) { sheet in
            SheetFactory.view(for: sheet)
        }
        .fullScreenCover(item: $coordinator.activeCover) { cover in
            CoverFactory.view(for: cover)
        }
        .environment(coordinator)
    }
}
