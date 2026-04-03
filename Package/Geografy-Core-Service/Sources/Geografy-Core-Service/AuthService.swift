import AuthenticationServices
import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
@MainActor
public final class AuthService {
    public enum AuthState {
        case guest(UserProfile)
        case authenticating
        case authenticated(UserProfile)
        case error(Error)
    }

    public private(set) var state: AuthState
    public private(set) var currentUserID: String

    private let db: DatabaseManager
    #if !os(tvOS)
    private let googleSignInHandler = GoogleSignInHandler()
    #endif

    public init(db: DatabaseManager) {
        self.db = db
        if let appleUserID = KeychainService.load(for: .appleUserID) {
            self.currentUserID = appleUserID
            self.state = .authenticating
        } else if let googleUserID = KeychainService.load(for: .googleUserID) {
            self.currentUserID = googleUserID
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

        if KeychainService.load(for: .googleUserID) != nil {
            validateGoogleSessionOnLaunch()
        } else if KeychainService.load(for: .appleUserID) != nil {
            await validateAppleSessionOnLaunch()
        } else {
            let profile = Self.loadOrCreateGuestProfile(id: currentUserID, db: db)
            state = .guest(profile)
        }
    }
}

// MARK: - Sign In with Google
#if !os(tvOS)
extension AuthService {
    public func signInWithGoogle() async {
        let previousState = state
        state = .authenticating
        do {
            let userInfo = try await googleSignInHandler.signIn()
            handleGoogleUserInfo(userInfo)
        } catch {
            let nsError = error as NSError
            if nsError.domain == "com.apple.AuthenticationServices.WebAuthenticationSession",
               nsError.code == 1 {
                state = previousState
            } else {
                state = .error(error)
            }
        }
    }
}
#endif

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
            try? db.mainContext.save()
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
            try? db.mainContext.save()
            currentUserID = appleUserID
            state = .authenticated(guestProfile)
        } else {
            let profile = UserProfile(
                id: appleUserID,
                displayName: fullName.isEmpty ? "Explorer" : fullName,
                email: email,
                isGuest: false
            )
            db.mainContext.insert(profile)
            try? db.mainContext.save()
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
            try? db.mainContext.save()
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
                try? db.mainContext.save()
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
                try? db.mainContext.save()
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
    func validateGoogleSessionOnLaunch() {
        if let profile = fetchProfile(id: currentUserID) {
            state = .authenticated(profile)
        } else {
            KeychainService.delete(for: .googleUserID)
            KeychainService.delete(for: .googleAccessToken)
            KeychainService.delete(for: .googleRefreshToken)
            transitionToGuest()
        }
    }

    func validateAppleSessionOnLaunch() async {
        let userID = currentUserID
        let credentialState = await fetchAppleCredentialState(userID: userID)
        switch credentialState {
        case .authorized:
            if let profile = fetchProfile(id: userID) {
                state = .authenticated(profile)
            } else {
                KeychainService.delete(for: .appleUserID)
                transitionToGuest()
            }
        case .revoked, .notFound, .transferred:
            KeychainService.delete(for: .appleUserID)
            transitionToGuest()
        @unknown default:
            KeychainService.delete(for: .appleUserID)
            transitionToGuest()
        }
    }

    #if !os(tvOS)
    func handleGoogleUserInfo(_ userInfo: GoogleUserInfo) {
        let googleUserID = "google:\(userInfo.sub)"
        KeychainService.save(googleUserID, for: .googleUserID)

        let displayName = [userInfo.givenName, userInfo.familyName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if let existingProfile = fetchProfile(id: googleUserID) {
            if case .guest(let guestProfile) = state {
                migrateGuestData(from: guestProfile.id, to: googleUserID)
            }
            existingProfile.isGuest = false
            existingProfile.lastLoginAt = .now
            if let email = userInfo.email { existingProfile.email = email }
            try? db.mainContext.save()
            currentUserID = googleUserID
            state = .authenticated(existingProfile)
        } else if case .guest(let guestProfile) = state {
            let oldGuestID = guestProfile.id
            migrateGuestData(from: oldGuestID, to: googleUserID)
            guestProfile.id = googleUserID
            guestProfile.isGuest = false
            if !displayName.isEmpty { guestProfile.displayName = displayName }
            if let email = userInfo.email { guestProfile.email = email }
            guestProfile.lastLoginAt = .now
            try? db.mainContext.save()
            currentUserID = googleUserID
            state = .authenticated(guestProfile)
        } else {
            let profile = UserProfile(
                id: googleUserID,
                displayName: displayName.isEmpty ? "Explorer" : displayName,
                email: userInfo.email,
                isGuest: false
            )
            db.mainContext.insert(profile)
            try? db.mainContext.save()
            currentUserID = googleUserID
            state = .authenticated(profile)
        }
    }
    #endif

    func clearAuthTokens() {
        KeychainService.delete(for: .appleUserID)
        KeychainService.delete(for: .googleUserID)
        KeychainService.delete(for: .googleAccessToken)
        KeychainService.delete(for: .googleRefreshToken)
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
        let profile = UserProfile(id: id, displayName: "Explorer", isGuest: true)
        db.mainContext.insert(profile)
        try? db.mainContext.save()
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
        let profile = UserProfile(id: newID, displayName: "Explorer", isGuest: true)
        db.mainContext.insert(profile)
        try? db.mainContext.save()
        currentUserID = newID
        state = .guest(profile)
    }

    func migrateGuestData(from guestID: String, to newID: String) {
        let xpDescriptor = FetchDescriptor<XPRecord>(predicate: #Predicate { $0.userID == guestID })
        let xpRecords = (try? db.mainContext.fetch(xpDescriptor)) ?? []
        for record in xpRecords { record.userID = newID }

        let quizDescriptor = FetchDescriptor<QuizHistoryRecord>(predicate: #Predicate { $0.userID == guestID })
        let quizRecords = (try? db.mainContext.fetch(quizDescriptor)) ?? []
        for record in quizRecords { record.userID = newID }

        let achievementDescriptor = FetchDescriptor<UnlockedAchievement>(predicate: #Predicate { $0.userID == guestID })
        let achievements = (try? db.mainContext.fetch(achievementDescriptor)) ?? []
        for record in achievements { record.userID = newID }

        let streakDescriptor = FetchDescriptor<StreakRecord>(predicate: #Predicate { $0.userID == guestID })
        let streaks = (try? db.mainContext.fetch(streakDescriptor)) ?? []
        for record in streaks { record.userID = newID }

        try? db.mainContext.save()
    }

    func deleteAllUserData(for userID: String) {
        let xpDescriptor = FetchDescriptor<XPRecord>(predicate: #Predicate { $0.userID == userID })
        let xpRecords = (try? db.mainContext.fetch(xpDescriptor)) ?? []
        for record in xpRecords { db.mainContext.delete(record) }

        let quizDescriptor = FetchDescriptor<QuizHistoryRecord>(predicate: #Predicate { $0.userID == userID })
        let quizRecords = (try? db.mainContext.fetch(quizDescriptor)) ?? []
        for record in quizRecords { db.mainContext.delete(record) }

        let achievementDescriptor = FetchDescriptor<UnlockedAchievement>(predicate: #Predicate { $0.userID == userID })
        let achievements = (try? db.mainContext.fetch(achievementDescriptor)) ?? []
        for record in achievements { db.mainContext.delete(record) }

        let streakDescriptor = FetchDescriptor<StreakRecord>(predicate: #Predicate { $0.userID == userID })
        let streaks = (try? db.mainContext.fetch(streakDescriptor)) ?? []
        for record in streaks { db.mainContext.delete(record) }

        let profileDescriptor = FetchDescriptor<UserProfile>(predicate: #Predicate { $0.id == userID })
        let profiles = (try? db.mainContext.fetch(profileDescriptor)) ?? []
        for profile in profiles { db.mainContext.delete(profile) }

        try? db.mainContext.save()
    }

    func fetchAppleCredentialState(userID: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        await withTaskGroup(of: ASAuthorizationAppleIDProvider.CredentialState.self) { group in
            group.addTask {
                await withCheckedContinuation { continuation in
                    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
                        continuation.resume(returning: state)
                    }
                }
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(5))
                return .notFound
            }
            let result = await group.next() ?? .notFound
            group.cancelAll()
            return result
        }
    }
}
