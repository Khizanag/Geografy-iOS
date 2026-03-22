import SwiftUI

enum HomeSheet: Identifiable {
    case quiz
    case signIn
    case profile
    case friends
    case allOrgs
    case orgDetail(Organization)
    case favorites
    case countries
    case coinStore
    case sectionEditor

    var id: String {
        switch self {
        case .quiz: "quiz"
        case .signIn: "signIn"
        case .profile: "profile"
        case .friends: "friends"
        case .allOrgs: "allOrgs"
        case .orgDetail(let organization): "orgDetail-\(organization.id)"
        case .favorites: "favorites"
        case .countries: "countries"
        case .coinStore: "coinStore"
        case .sectionEditor: "sectionEditor"
        }
    }
}

struct HomeSheetsModifier: ViewModifier {
    @Binding var activeSheet: HomeSheet?
    let sectionOrder: [HomeSection]

    func body(content: Content) -> some View {
        content
            .sheet(item: $activeSheet) { sheet in
                sheetContent(for: sheet)
            }
    }
}

// MARK: - Sheet Content

private extension HomeSheetsModifier {
    @ViewBuilder
    func sheetContent(for sheet: HomeSheet) -> some View {
        switch sheet {
        case .quiz:
            QuizSetupScreen()
        case .signIn:
            SignInOptionsSheet()
        case .profile:
            profileSheet
        case .friends:
            ComingSoonSheet(title: "Friends", icon: "person.2.fill")
        case .allOrgs:
            sheetWithCloseButton { OrganizationsScreen() }
        case .orgDetail(let organization):
            sheetWithCloseButton { OrganizationDetailScreen(organization: organization) }
        case .favorites:
            sheetWithCloseButton { FavoritesScreen() }
        case .countries:
            sheetWithCloseButton { CountryListScreen() }
        case .coinStore:
            CoinStoreScreen()
        case .sectionEditor:
            HomeSectionEditorSheet(sections: sectionOrder)
        }
    }
}

// MARK: - Subviews

private extension HomeSheetsModifier {
    var profileSheet: some View {
        NavigationStack {
            ProfileScreen()
        }
        .presentationDetents([.large])
    }

    func sheetWithCloseButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            content()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CircleCloseButton()
                    }
                }
        }
    }
}
