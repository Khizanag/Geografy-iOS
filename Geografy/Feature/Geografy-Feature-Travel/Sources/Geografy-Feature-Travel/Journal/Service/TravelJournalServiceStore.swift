/// Makes the journal service on first use and keeps it.
///
/// `@State` builds its initial value on every init of the view that holds it, and each service
/// opens its own SwiftData container; a lazy holder means only the store `@State` keeps ever makes one.
@MainActor
final class TravelJournalServiceStore {
    lazy var service = TravelJournalService()
}
