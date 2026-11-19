import AuthenticationServices
import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
@MainActor
public final class AuthService {
    /// The name a profile starts with until its owner sets one.
    public static let defaultDisplayName = "Explorer"

    public enum AuthState {
        case guest(UserProfile)
        case authenticating
        case authenticated(UserProfile)
        case error(Error)
    }

    public private(set) var state: AuthState
    public private(set) var currentUserID: String

    private let db: DatabaseManager

    public init(db: DatabaseManager) {
        self.db = db
        if let appleUserID = KeychainService.load(for: .appleUserID) {
            self.currentUserID = appleUserID
            self.state = .authenticating
        } else {
            let guestID = Self.resolveGuestID()
            self.currentUserID = guestID
            self.state = .authenticating
        }
    }

    public var currentProfile: UserProfile? {
        switch state {
        case .guest(let profile): profile
        case .authenticated(let profile): profile
        default: nil
        }
    }

    public var isGuest: Bool {
        if case .guest = state { return true }
        return false
    }
}

// MARK: - Launch
extension AuthService {
    public func validateOnLaunch() async {
        guard case .authenticating = state else { return }

        if KeychainService.load(for: .appleUserID) != nil {
            await validateAppleSessionOnLaunch()
        } else {
            let profile = Self.loadOrCreateGuestProfile(id: currentUserID, db: db)
            state = .guest(profile)
        }
    }
}

// MARK: - Sign In
extension AuthService {
    public func handleAppleSignIn(_ authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        let appleUserID = credential.user
        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let email = credential.email

        KeychainService.save(appleUserID, for: .appleUserID)

        if let existingProfile = fetchProfile(id: appleUserID) {
            if case .guest(let guestProfile) = state {
                migrateGuestData(from: guestProfile.id, to: appleUserID)
            }
            existingProfile.isGuest = false
            existingProfile.lastLoginAt = .now
            if let email { existingProfile.email = email }
            db.mainContext.saveOrLog()
            currentUserID = appleUserID
            state = .authenticated(existingProfile)
        } else if case .guest(let guestProfile) = state {
            let oldGuestID = guestProfile.id
            migrateGuestData(from: oldGuestID, to: appleUserID)
            guestProfile.id = appleUserID
            guestProfile.isGuest = false
            if !fullName.isEmpty { guestProfile.displayName = fullName }
            if let email { guestProfile.email = email }
            guestProfile.lastLoginAt = .now
            db.mainContext.saveOrLog()
            currentUserID = appleUserID
            state = .authenticated(guestProfile)
        } else {
            let profile = UserProfile(
                id: appleUserID,
                displayName: fullName.isEmpty ? Self.defaultDisplayName : fullName,
                email: email,
                isGuest: false
            )
            db.mainContext.insert(profile)
            db.mainContext.saveOrLog()
            currentUserID = appleUserID
            state = .authenticated(profile)
        }
    }
}

// MARK: - Debug Sign In
#if DEBUG
extension AuthService {
    public func debugSignIn() {
        let debugID = "debug-user-giga"
        KeychainService.save(debugID, for: .appleUserID)

        if let existing = fetchProfile(id: debugID) {
            if case .guest(let guestProfile) = state {
                migrateGuestData(from: guestProfile.id, to: debugID)
            }
            existing.isGuest = false
            existing.displayName = "Giga"
            existing.email = "giga.khizanishvili@gmail.com"
            existing.lastLoginAt = .now
            db.mainContext.saveOrLog()
            currentUserID = debugID
            state = .authenticated(existing)
        } else {
            if case .guest(let guestProfile) = state {
                migrateGuestData(from: guestProfile.id, to: debugID)
                guestProfile.id = debugID
                guestProfile.isGuest = false
                guestProfile.displayName = "Giga"
                guestProfile.email = "giga.khizanishvili@gmail.com"
                guestProfile.lastLoginAt = .now
                db.mainContext.saveOrLog()
                currentUserID = debugID
                state = .authenticated(guestProfile)
            } else {
                let profile = UserProfile(
                    id: debugID,
                    displayName: "Giga",
                    email: "giga.khizanishvili@gmail.com",
                    isGuest: false
                )
                db.mainContext.insert(profile)
                db.mainContext.saveOrLog()
                currentUserID = debugID
                state = .authenticated(profile)
            }
        }
    }
}
#endif

// MARK: - Sign Out / Delete
extension AuthService {
    public func signOut() {
        clearAuthTokens()
        transitionToGuest()
    }

    public func deleteAccount() {
        if let profile = currentProfile {
            deleteAllUserData(for: profile.id)
        }
        clearAuthTokens()
        KeychainService.delete(for: .guestUUID)
        transitionToFreshGuest()
    }
}

// MARK: - Helpers
private extension AuthService {
    func validateAppleSessionOnLaunch() async {
        let userID = currentUserID
        switch await AppleCredentialCheck.resolve(userID: userID) {
        case .authorized:
            if let profile = fetchProfile(id: userID) {
                state = .authenticated(profile)
            } else {
                KeychainService.delete(for: .appleUserID)
                transitionToGuest()
            }
        case .revoked:
            KeychainService.delete(for: .appleUserID)
            transitionToGuest()
        case .unknown:
            // Keep the Keychain ID so the next launch checks again.
            if let profile = fetchProfile(id: userID) {
                state = .authenticated(profile)
            } else {
                transitionToGuest()
            }
        }
    }

    func clearAuthTokens() {
        KeychainService.delete(for: .appleUserID)
    }

    static func resolveGuestID() -> String {
        if let keychainID = KeychainService.load(for: .guestUUID) {
            return keychainID
        }
        if let defaultsID = UserDefaults.standard.string(forKey: "guest_user_id") {
            KeychainService.save(defaultsID, for: .guestUUID)
            return defaultsID
        }
        let newID = UUID().uuidString
        KeychainService.save(newID, for: .guestUUID)
        return newID
    }

    static func loadOrCreateGuestProfile(id: String, db: DatabaseManager) -> UserProfile {
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.id == id }
        )
        if let existing = (try? db.mainContext.fetch(descriptor))?.first {
            return existing
        }
        let profile = UserProfile(id: id, displayName: Self.defaultDisplayName, isGuest: true)
        db.mainContext.insert(profile)
        db.mainContext.saveOrLog()
        return profile
    }

    func fetchProfile(id: String) -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? db.mainContext.fetch(descriptor))?.first
    }

    func transitionToGuest() {
        let guestID = Self.resolveGuestID()
        let profile = Self.loadOrCreateGuestProfile(id: guestID, db: db)
        currentUserID = guestID
        state = .guest(profile)
    }

    func transitionToFreshGuest() {
        let newID = UUID().uuidString
        KeychainService.save(newID, for: .guestUUID)
        let profile = UserProfile(id: newID, displayName: Self.defaultDisplayName, isGuest: true)
        db.mainContext.insert(profile)
        db.mainContext.saveOrLog()
        currentUserID = newID
        state = .guest(profile)
    }
}

// MARK: - User Data
extension AuthService {
    /// Hands a guest's progress to the account they sign in to: every record in the store and everything kept
    /// per user in `UserDefaults`.
    func migrateGuestData(from guestID: String, to newID: String) {
        let context = db.mainContext
        for record in Self.records(XPRecord.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        for record in Self.records(QuizHistoryRecord.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        let achievements = Self.records(
            UnlockedAchievement.self,
            matching: #Predicate { $0.userID == guestID },
            in: context
        )
        for record in achievements {
            record.userID = newID
        }
        for record in Self.records(StreakRecord.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        for record in Self.records(FavoriteEntry.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        for record in Self.records(CollectionItem.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        for record in Self.records(SavedCollection.self, matching: #Predicate { $0.userID == guestID }, in: context) {
            record.userID = newID
        }
        context.saveOrLog()
        UserScope.moveData(from: guestID, to: newID)
    }

    /// Deletes everything the user has: every record in the store, their profile, and everything kept per user
    /// in `UserDefaults`.
    func deleteAllUserData(for userID: String) {
        let context = db.mainContext
        let models: [[any PersistentModel]] = [
            Self.records(XPRecord.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(QuizHistoryRecord.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(UnlockedAchievement.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(StreakRecord.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(FavoriteEntry.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(CollectionItem.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(SavedCollection.self, matching: #Predicate { $0.userID == userID }, in: context),
            Self.records(UserProfile.self, matching: #Predicate { $0.id == userID }, in: context),
        ]
        for model in models.joined() {
            context.delete(model)
        }
        context.saveOrLog()
        UserScope.removeData(of: userID)
    }

    static func records<Model: PersistentModel>(
        _ type: Model.Type,
        matching predicate: Predicate<Model>,
        in context: ModelContext
    ) -> [Model] {
        (try? context.fetch(FetchDescriptor(predicate: predicate))) ?? []
    }
}
