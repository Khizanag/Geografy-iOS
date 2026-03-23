# Guest-to-Account Migration

Research document on anonymous auth patterns, data migration, and best practices for converting guest users to authenticated accounts in iOS apps.

---

## Current App State

From `Auth/View/SignInOptionsSheet.swift` and the navigation stack, the app supports:
- **Google Sign In**
- **Apple Sign In**
- **Guest mode** (GuestModePromptBanner.swift exists)

Data stored includes: XP records, quiz history, achievements, travel status, favorites, streaks, user profile — all in SwiftData.

---

## The Core Problem

Guest users accumulate valuable data: XP, quiz scores, streaks, achievements, visited countries. When they sign up, this data must not be lost. Three scenarios:

1. **Guest signs up (no prior account)** → attach local data to new account, easy
2. **Guest signs in to existing account** → merge or replace conflict; harder
3. **Guest never signs in** → data lives locally; if app deleted, data gone

---

## Standard Patterns

### Pattern 1: Local-First with Cloud Sync on Auth

The cleanest architecture for a primarily offline app:

```
Guest state:
  - SwiftData stores all data locally
  - No user ID; data is unowned (or owned by a local UUID "device ID")

On sign-in:
  - Authenticate with Apple/Google → get user ID
  - Mark all local data with the user ID
  - If backend sync enabled: upload local data to server
  - If conflict: apply merge strategy
```

**Implementation for Geografy** (pure offline app):
- On first launch, generate a local `guestSessionID: UUID` (stored in UserDefaults / Keychain)
- All SwiftData models get a `userID: String` field (either guestSessionID or real user ID)
- On sign-in: update all records' `userID` to the authenticated user's ID
- If the user later signs in on another device: their remote profile loads (empty) — offer to keep local data or start fresh

---

### Pattern 2: Anonymous Firebase Auth (if backend is added)

Firebase Auth provides `signInAnonymously()` which creates a real UID for the guest. When they later sign in with Apple/Google, Firebase's `link()` method merges the anonymous account into the real account seamlessly:

```swift
// Guest creates anonymous auth account
Auth.auth().signInAnonymously { result, error in
    let anonymousUser = result?.user  // Has a real UID
    // All data is stored under this UID
}

// Later, when guest taps "Sign in with Apple"
let credential = OAuthProvider.credential(...)
anonymousUser.link(with: credential) { result, error in
    if let error = error as NSError?,
       error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
        // User already has an account — handle merge
        let existingCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey]
        Auth.auth().signIn(with: existingCredential) { ... }
    }
    // Success: anonymous UID becomes the real user's UID, all data preserved
}
```

**Geografy verdict**: Not using Firebase yet; this is the right pattern to adopt if backend is added.

---

### Pattern 3: Pure Local SwiftData (current architecture)

Since Geografy is offline-first with no backend, the simplest correct approach:

```swift
// On app first launch
func getOrCreateGuestProfile() -> UserProfile {
    if let existing = try? context.fetch(UserProfile.all).first {
        return existing
    }
    let guest = UserProfile(id: UUID().uuidString, displayName: "Explorer", isGuest: true)
    context.insert(guest)
    return guest
}

// On sign-in
func upgradeGuestToAccount(appleUserID: String, email: String?, name: String?) {
    guard let guest = currentProfile, guest.isGuest else { return }
    guest.isGuest = false
    guest.authProvider = "apple"
    guest.authID = appleUserID
    guest.email = email
    guest.displayName = name ?? guest.displayName
    // All XP, achievements, travel data are already associated with this profile — done
}
```

This works because SwiftData objects are local, and the `UserProfile` just needs its identity fields updated.

---

## Apple Sign In — Best Practices

### What to request
```swift
let request = ASAuthorizationAppleIDProvider().createRequest()
request.requestedScopes = [.fullName, .email]
// Note: Apple ONLY sends name/email on FIRST sign-in
// Cache them immediately — never available again
```

### Store in Keychain
```swift
// Store Apple user ID in Keychain (NOT UserDefaults — can be cleared)
KeychainHelper.save(appleUserID, for: "apple_user_id")

// Check credential state on each launch
ASAuthorizationAppleIDProvider().getCredentialState(forUserID: storedID) { state, _ in
    switch state {
    case .authorized: break  // Still valid
    case .revoked, .notFound:
        // User revoked — sign out
    }
}
```

### Credential Revocation
- Apple can revoke authorization without notice (user revokes in Settings)
- Must check `getCredentialState` on each app launch
- If revoked: clear auth state, revert to guest mode (keep local data)

---

## Data Migration Strategy

### SwiftData Migration on Sign-In

```swift
@MainActor
func migrateGuestDataToAccount(newUserID: String, modelContext: ModelContext) async throws {
    // All models that have a userID field need to be updated
    let descriptor = FetchDescriptor<XPRecord>()
    let records = try modelContext.fetch(descriptor)
    records.forEach { $0.userID = newUserID }

    let quizHistory = try modelContext.fetch(FetchDescriptor<QuizHistoryRecord>())
    quizHistory.forEach { $0.userID = newUserID }

    // ... repeat for StreakRecord, UnlockedAchievement, TravelStatus items, etc.

    try modelContext.save()
}
```

### Conflict Scenario: User Already Has Account

If a guest signs in to a previously used account (e.g., on new device):

**Option A: Keep local (guest) data**
- Replace cloud/remote profile with local data
- Best if local data is richer (played more as guest)

**Option B: Keep remote data**
- Discard local guest data
- Best if remote account has progression

**Option C: Merge (complex)**
- Take max XP
- Union of achievements
- Union of visited countries
- Keep higher streak

**Recommendation for Geografy**: Show a dialog:
```
"You already have a Geografy account. What would you like to do?"
[Keep your guest progress] [Use your existing account] [Merge both]
```
Only implement merge if explicitly requested — it's complex. For v1, offer Keep Local vs. Use Existing.

---

## Keychain Storage Pattern

For durable storage that survives app reinstall (on same device):

```swift
import Security

struct KeychainHelper {
    static func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func load(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var dataRef: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &dataRef)
        guard let data = dataRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
```

**What to store in Keychain for Geografy**:
- `apple_user_id` — Apple's userIdentifier
- `guest_session_id` — UUID for guest, persists across reinstalls on same device
- `auth_provider` — "apple", "google", or "guest"

---

## Guest Mode UX Patterns

### Best Practices from Top Apps (Duolingo, Wordle, etc.)

1. **Don't gate content behind auth** — let guests play everything
2. **Progressive prompts** — show sign-up prompt after meaningful achievement ("You reached level 3! Sign up to save your progress")
3. **Data loss warning** — when guest tries to do something that requires account (e.g., leaderboard), explain data will be lost if they uninstall
4. **Seamless continuation** — after sign-up, return to exactly where they were

### Prompt Timing for Geografy
Show the `GuestModePromptBanner` (already exists) at:
- After completing first quiz (low friction)
- When streak hits 3 days ("Save your 3-day streak!")
- When reaching Level 2
- When user visits Profile tab
- After unlocking first achievement

### What NOT to do
- Don't require account to view country details
- Don't interrupt gameplay for sign-up prompts
- Don't delete guest data on sign-out (keep it until they explicitly clear)

---

## SwiftData Migration Versioning

If `UserProfile` needs a new field for `authProvider`, use `@Attribute` with default values to avoid migration failures:

```swift
@Model
final class UserProfile {
    // Existing fields...
    var isGuest: Bool = true
    var authProvider: String = "guest"  // "apple", "google", "guest"
    var authID: String = ""
    // New fields always need default values for migration
}
```

For more complex migrations, use `SchemaMigrationPlan` with `MigrationStage.lightweight` for additive changes.

---

## Summary: Recommended Implementation Plan

1. **Immediate**: Ensure `UserProfile` has `isGuest: Bool`, `authProvider: String`, `authID: String` fields
2. **Immediate**: Store Apple User ID in Keychain on sign-in
3. **Immediate**: Implement `upgradeGuestToAccount()` that updates `UserProfile` fields only (all other data naturally associated)
4. **Short-term**: Add credential state check on app launch (for Apple revocation)
5. **Short-term**: Show sign-up prompts at appropriate milestone moments
6. **Long-term**: If backend added, adopt Firebase anonymous auth pattern for true multi-device sync
