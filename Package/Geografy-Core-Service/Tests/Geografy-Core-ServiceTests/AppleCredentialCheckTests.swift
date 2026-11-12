import AuthenticationServices
@testable import Geografy_Core_Service
import Testing

@Suite("AppleCredentialCheck")
struct AppleCredentialCheckTests {
    struct CredentialError: Error {}

    static let stateMappings: [(ASAuthorizationAppleIDProvider.CredentialState, AppleCredentialCheck)] = [
        (.authorized, .authorized),
        (.revoked, .revoked),
        (.notFound, .revoked),
        (.transferred, .revoked),
    ]

    @Test("Maps credential states", arguments: stateMappings)
    func mapsStates(state: ASAuthorizationAppleIDProvider.CredentialState, expected: AppleCredentialCheck) {
        #expect(AppleCredentialCheck(state: state, error: nil) == expected)
    }

    @Test("An error is unknown, not revoked")
    func errorIsUnknown() {
        #expect(AppleCredentialCheck(state: .notFound, error: CredentialError()) == .unknown)
    }

    @Test("A request that never answers times out as unknown")
    func timeoutIsUnknown() async {
        let result = await AppleCredentialCheck.resolve(timeout: .milliseconds(50)) { _ in }

        #expect(result == .unknown)
    }

    @Test("A prompt answer wins over the timeout")
    func answerBeforeTimeout() async {
        let result = await AppleCredentialCheck.resolve(timeout: .seconds(5)) { completion in
            completion(.authorized, nil)
        }

        #expect(result == .authorized)
    }
}
