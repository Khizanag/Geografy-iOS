import AuthenticationServices
import Synchronization

/// The outcome of checking a stored Apple ID on launch.
///
/// `unknown` covers timeouts and errors, so a slow or offline launch keeps the cached session
/// instead of treating it as revoked.
enum AppleCredentialCheck: Equatable, Sendable {
    case authorized
    case revoked
    case unknown

    typealias Completion = @Sendable (ASAuthorizationAppleIDProvider.CredentialState, (any Error)?) -> Void

    init(state: ASAuthorizationAppleIDProvider.CredentialState, error: (any Error)?) {
        guard error == nil else {
            self = .unknown
            return
        }
        switch state {
        case .authorized: self = .authorized
        case .revoked, .notFound, .transferred: self = .revoked
        @unknown default: self = .unknown
        }
    }
}

// MARK: - Resolve
extension AppleCredentialCheck {
    static func resolve(userID: String, timeout: Duration = .seconds(5)) async -> AppleCredentialCheck {
        await resolve(timeout: timeout) { completion in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID, completion: completion)
        }
    }

    // The provider's callback can't be cancelled, so the timeout races it and the first one resumes.
    static func resolve(
        timeout: Duration,
        request: @Sendable (@escaping Completion) -> Void
    ) async -> AppleCredentialCheck {
        await withCheckedContinuation { continuation in
            let resumeOnce = ResumeOnce()
            request { state, error in
                guard resumeOnce.claim() else { return }
                continuation.resume(returning: AppleCredentialCheck(state: state, error: error))
            }
            Task {
                try? await Task.sleep(for: timeout)
                guard resumeOnce.claim() else { return }
                continuation.resume(returning: .unknown)
            }
        }
    }
}

// MARK: - ResumeOnce
private final class ResumeOnce: Sendable {
    private let isClaimed = Mutex(false)

    func claim() -> Bool {
        isClaimed.withLock { isClaimed in
            guard !isClaimed else { return false }
            isClaimed = true
            return true
        }
    }
}
