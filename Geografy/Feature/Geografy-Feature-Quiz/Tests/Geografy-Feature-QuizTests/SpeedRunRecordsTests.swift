import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Quiz
import Testing

@Suite("SpeedRunRecords", .serialized)
struct SpeedRunRecordsTests {
    @Test("The first complete run sets the record")
    func firstRunIsRecord() {
        UserScope.activate(UUID().uuidString)

        #expect(SpeedRunRecords.record(90, for: .africa))
        #expect(SpeedRunRecords.bestTime(for: .africa) == 90)
    }

    @Test("Only a faster run replaces the record")
    func onlyFasterRunReplaces() {
        UserScope.activate(UUID().uuidString)
        SpeedRunRecords.record(90, for: .asia)

        #expect(!SpeedRunRecords.record(120, for: .asia))
        #expect(SpeedRunRecords.record(60, for: .asia))
        #expect(SpeedRunRecords.bestTime(for: .asia) == 60)
    }

    @Test("Records belong to the user who set them")
    func recordsArePerUser() {
        UserScope.activate(UUID().uuidString)
        SpeedRunRecords.record(45, for: .world)

        UserScope.activate(UUID().uuidString)

        #expect(SpeedRunRecords.bestTime(for: .world) == nil)
    }
}
