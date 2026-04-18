#if canImport(CloudKit)
import CloudKit
#endif
import Foundation
import Observation
import os

/// Facade around a future CloudKit + SwiftData mirror of user progress.
///
/// This scaffold checks iCloud availability, exposes an opt-in toggle, and
/// publishes a status the UI can react to (Settings row, Premium anchor).
/// The actual record-sync logic lands once the Xcode target gains the
/// `iCloud` capability with a dedicated container identifier — until then,
/// ``sync()`` is a no-op that records what *would* have been synced.
@Observable
@MainActor
public final class CloudSyncService {
    public enum Status: Sendable, Equatable {
        case disabled
        case unavailable(reason: String)
        case ready
        case syncing
        case synced(at: Date)
        case failed(reason: String)
    }

    public static let enabledKey = "cloud_sync_enabled"

    public private(set) var status: Status = .disabled

    private let logger = Logger(subsystem: "com.khizanag.geografy", category: "cloud-sync")

    public init() {
        let enabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
        status = enabled ? .ready : .disabled
        Task { await refreshAvailability() }
    }

    public var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: Self.enabledKey)
    }

    public func setEnabled(_ enabled: Bool) async {
        UserDefaults.standard.set(enabled, forKey: Self.enabledKey)
        if enabled {
            await refreshAvailability()
            if case .ready = status {
                await sync()
            }
        } else {
            status = .disabled
        }
    }

    /// Probe CloudKit for account availability. Updates ``status``.
    public func refreshAvailability() async {
        guard isEnabled else {
            status = .disabled
            return
        }
        #if canImport(CloudKit)
        do {
            let container = CKContainer.default()
            let accountStatus = try await container.accountStatus()
            switch accountStatus {
            case .available:
                status = .ready
            case .noAccount:
                status = .unavailable(reason: "Sign in to iCloud in Settings to enable sync.")
            case .restricted:
                status = .unavailable(reason: "iCloud is restricted on this device.")
            case .couldNotDetermine:
                status = .unavailable(reason: "iCloud status could not be determined.")
            case .temporarilyUnavailable:
                status = .unavailable(reason: "iCloud is temporarily unavailable.")
            @unknown default:
                status = .unavailable(reason: "Unknown iCloud status.")
            }
        } catch {
            status = .failed(reason: error.localizedDescription)
        }
        #else
        status = .unavailable(reason: "iCloud not available on this platform.")
        #endif
    }

    /// Placeholder sync entry point. Swap in real CKModifyRecordsOperation
    /// (or NSPersistentCloudKitContainer) once the iCloud entitlement is
    /// enabled in Xcode for the target.
    public func sync() async {
        guard isEnabled else { return }
        status = .syncing
        logger.info("cloud-sync: sync() invoked — stub implementation; entitlement not yet wired")
        try? await Task.sleep(for: .milliseconds(400))
        status = .synced(at: Date())
    }
}
