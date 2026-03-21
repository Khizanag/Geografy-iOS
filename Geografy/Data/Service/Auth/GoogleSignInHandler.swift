// MARK: - Google OAuth2 Setup Instructions
//
// To enable Google Sign In, complete the following steps:
//
// 1. Create or open a project at https://console.cloud.google.com/
// 2. Enable the "Google People API" (or "Google Identity Services")
// 3. Go to "APIs & Services" → "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
//    • Application type: iOS
//    • Bundle ID: com.khizanag.geografy
// 4. Download the generated `GoogleService-Info.plist` (optional) and note the CLIENT_ID
// 5. Replace `GoogleSignInHandler.clientID` below with the CLIENT_ID value
//    (format: XXXXXXXXXX.apps.googleusercontent.com)
// 6. In Xcode → project target → Info → URL Types, add a new entry:
//    • Identifier: Google Sign In
//    • URL Schemes: the REVERSED client ID, e.g. com.googleusercontent.apps.XXXXXXXXXX

import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

// MARK: - GoogleUserInfo

struct GoogleUserInfo {
    let sub: String
    let email: String?
    let name: String?
    let givenName: String?
    let familyName: String?
}

// MARK: - GoogleSignInHandler

@MainActor
final class GoogleSignInHandler: NSObject {
    /// Replace with your Google OAuth 2.0 Client ID from Google Cloud Console.
    /// Format: XXXXXXXXXX.apps.googleusercontent.com
    static let clientID = "PLACEHOLDER_GOOGLE_CLIENT_ID.apps.googleusercontent.com"

    private static let authorizationEndpoint = makeURL(
        "https://accounts.google.com/o/oauth2/v2/auth"
    )
    private static let tokenEndpoint = makeURL(
        "https://oauth2.googleapis.com/token"
    )
    private static let userInfoEndpoint = makeURL(
        "https://www.googleapis.com/oauth2/v3/userinfo"
    )

    private static func makeURL(_ string: String) -> URL {
        guard let url = URL(string: string) else {
            fatalError("Invalid hardcoded URL: \(string)")
        }
        return url
    }

    private static var redirectURI: String {
        let reversed = clientID
            .components(separatedBy: ".")
            .reversed()
            .joined(separator: ".")
        return "\(reversed):/oauth2callback"
    }

    private var currentSession: ASWebAuthenticationSession?
    private let presentationContext = PresentationContextProvider()

    func signIn() async throws -> GoogleUserInfo {
        let (codeVerifier, codeChallenge) = makePKCEPair()
        let state = UUID().uuidString

        let authURL = buildAuthURL(codeChallenge: codeChallenge, state: state)

        let code: String = try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard
                    let callbackURL,
                    let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                    let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                else {
                    continuation.resume(throwing: GoogleSignInError.invalidCallback)
                    return
                }
                continuation.resume(returning: code)
            }
            session.presentationContextProvider = self.presentationContext
            session.prefersEphemeralWebBrowserSession = false
            self.currentSession = session
            session.start()
        }

        let tokens = try await exchangeCodeForTokens(code: code, codeVerifier: codeVerifier)
        let userInfo = try await fetchUserInfo(accessToken: tokens.accessToken)

        KeychainService.save(tokens.accessToken, for: .googleAccessToken)
        if let refresh = tokens.refreshToken {
            KeychainService.save(refresh, for: .googleRefreshToken)
        }

        return userInfo
    }
}

// MARK: - Error

extension GoogleSignInHandler {
    enum GoogleSignInError: LocalizedError {
        case invalidCallback
        case tokenExchangeFailed(String)
        case userInfoFetchFailed
        case missingUserID

        var errorDescription: String? {
            switch self {
            case .invalidCallback:
                "The Google sign-in callback URL was invalid."
            case .tokenExchangeFailed(let detail):
                "Token exchange failed: \(detail)"
            case .userInfoFetchFailed:
                "Failed to fetch your Google profile."
            case .missingUserID:
                "Google did not return a user identifier."
            }
        }
    }
}

// MARK: - PKCE

private extension GoogleSignInHandler {
    func makePKCEPair() -> (verifier: String, challenge: String) {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        let verifier = Data(bytes).base64URLEncoded()
        let challengeData = Data(SHA256.hash(data: Data(verifier.utf8)))
        let challenge = challengeData.base64URLEncoded()
        return (verifier, challenge)
    }
}

// MARK: - Auth URL

private extension GoogleSignInHandler {
    var callbackScheme: String {
        Self.clientID
            .components(separatedBy: ".")
            .reversed()
            .joined(separator: ".")
    }

    func buildAuthURL(codeChallenge: String, state: String) -> URL {
        guard var components = URLComponents(
            url: Self.authorizationEndpoint,
            resolvingAgainstBaseURL: false
        ) else {
            fatalError("Invalid authorization endpoint URL")
        }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Self.clientID),
            URLQueryItem(name: "redirect_uri", value: Self.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid email profile"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state),
        ]
        guard let url = components.url else {
            fatalError("Failed to build authorization URL")
        }
        return url
    }
}

// MARK: - Token Exchange

private extension GoogleSignInHandler {
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }

    func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> TokenResponse {
        var request = URLRequest(url: Self.tokenEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let params: [(String, String)] = [
            ("code", code),
            ("client_id", Self.clientID),
            ("redirect_uri", Self.redirectURI),
            ("grant_type", "authorization_code"),
            ("code_verifier", codeVerifier),
        ]
        request.httpBody = params
            .map { "\($0.0)=\($0.1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.1)" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}

// MARK: - User Info

private extension GoogleSignInHandler {
    struct RawUserInfo: Decodable {
        let sub: String?
        let email: String?
        let name: String?
        let givenName: String?
        let familyName: String?

        enum CodingKeys: String, CodingKey {
            case sub, email, name
            case givenName = "given_name"
            case familyName = "family_name"
        }
    }

    func fetchUserInfo(accessToken: String) async throws -> GoogleUserInfo {
        var request = URLRequest(url: Self.userInfoEndpoint)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let raw = try JSONDecoder().decode(RawUserInfo.self, from: data)
        guard let sub = raw.sub else { throw GoogleSignInError.missingUserID }
        return GoogleUserInfo(
            sub: sub,
            email: raw.email,
            name: raw.name,
            givenName: raw.givenName,
            familyName: raw.familyName
        )
    }
}

// MARK: - Presentation Context

private final class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Data+Base64URL

private extension Data {
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
