import SwiftUI

/// What a search shows when nothing matches, in the app's own words: `ContentUnavailableView.search` reads the
/// system's strings, which some languages don't have.
public struct NoSearchResultsView: View {
    // MARK: - Properties
    private let query: String

    // MARK: - Init
    public init(query: String) {
        self.query = query
    }

    // MARK: - Body
    public var body: some View {
        ContentUnavailableView {
            Label {
                Text("No Results for “\(query)”", bundle: .module)
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        } description: {
            Text("Check the spelling or try a new search.", bundle: .module)
        }
    }
}
