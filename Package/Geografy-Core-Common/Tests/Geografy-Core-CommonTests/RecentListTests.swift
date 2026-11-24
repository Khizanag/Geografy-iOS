@testable import Geografy_Core_Common
import Testing

@Suite("Recent list")
struct RecentListTests {
    @Test("Removing drops the item and its repeats, keeping the rest in order")
    func removing() {
        let recents = RecentList<[String]>(storageKey: "test", limit: 5) { lhs, rhs in
            lhs == rhs || lhs == rhs.reversed()
        }
        let items = [["GE", "AM"], ["FR", "DE"], ["AM", "GE"], ["JP", "KR"]]

        let remaining = recents.removing(["GE", "AM"], from: items)

        #expect(remaining == [["FR", "DE"], ["JP", "KR"]])
    }
}
