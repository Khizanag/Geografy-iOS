import Geografy_Core_Common
@testable import Geografy_Core_Service
import Testing

@Suite("TravelService")
struct TravelServiceTests {
    @Test("Visited and wishlist codes follow each status change")
    func codeSetsFollowStatusChanges() {
        let service = TravelService()
        let original = service.entries
        defer { restore(original, in: service) }

        service.set(status: .visited, for: "ZZ")
        service.set(status: .wantToVisit, for: "ZY")
        #expect(service.visitedCodes.contains("ZZ"))
        #expect(service.wantToVisitCodes.contains("ZY"))

        service.set(status: .wantToVisit, for: "ZZ")
        service.set(status: nil, for: "ZY")
        #expect(!service.visitedCodes.contains("ZZ"))
        #expect(service.wantToVisitCodes == Set(service.entries.filter { $0.value == .wantToVisit }.keys))
    }
}

// MARK: - Helpers
private extension TravelServiceTests {
    func restore(_ entries: [String: TravelStatus], in service: TravelService) {
        for code in service.entries.keys where entries[code] == nil {
            service.set(status: nil, for: code)
        }
        for (code, status) in entries {
            service.set(status: status, for: code)
        }
    }
}
