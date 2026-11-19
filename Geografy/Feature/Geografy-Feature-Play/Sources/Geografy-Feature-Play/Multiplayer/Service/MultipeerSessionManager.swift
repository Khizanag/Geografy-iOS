#if !os(tvOS)
import MultipeerConnectivity
import os

@MainActor
@Observable
public final class MultipeerSessionManager: NSObject, @unchecked Sendable {
    private(set) var connectedPeers: [MCPeerID] = []
    private(set) var discoveredPeers: [MCPeerID] = []
    private(set) var lastReceivedMessage: (peer: MCPeerID, message: PeerMessage)?
    /// iOS refused to advertise or browse, usually because Local Network access is off for the app.
    private(set) var isDiscoveryBlocked = false

    private let serviceType = "geografy-quiz"
    private let myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let logger = Logger(subsystem: "com.khizanag.geografy", category: "multipeer")

    public var onMessageReceived: ((MCPeerID, PeerMessage) -> Void)?
    public var onPeerStateChanged: ((MCPeerID, MCSessionState) -> Void)?

    /// - Parameter displayName: The name nearby players see. iOS caps it at 63 bytes.
    init(displayName: String) {
        self.myPeerID = MCPeerID(displayName: Self.peerName(displayName))
        super.init()
    }

    /// Closes the connection when the screen that owns the match goes away mid-game, so the other phone hears it.
    isolated deinit {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
}

// MARK: - Public API
extension MultipeerSessionManager {
    public func startAdvertising() {
        let newSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        newSession.delegate = self
        session = newSession

        let newAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        newAdvertiser.delegate = self
        isDiscoveryBlocked = false
        newAdvertiser.startAdvertisingPeer()
        advertiser = newAdvertiser
    }

    public func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    public func startBrowsing() {
        let newSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        newSession.delegate = self
        session = newSession

        let newBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        newBrowser.delegate = self
        isDiscoveryBlocked = false
        newBrowser.startBrowsingForPeers()
        browser = newBrowser
    }

    public func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    public func invitePeer(_ peerID: MCPeerID) {
        guard let session else { return }
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    public func send(_ message: PeerMessage) {
        guard let session, !session.connectedPeers.isEmpty else { return }
        guard let data = try? message.encode() else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    /// Tells the other player you're leaving, then closes the connection once the message has had time to go out.
    public func disconnect() {
        send(.disconnecting)
        let closing = session
        stopAdvertising()
        stopBrowsing()
        connectedPeers = []
        discoveredPeers = []
        session = nil
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            closing?.disconnect()
        }
    }

    /// Closes the connection without a goodbye, for when the other player is already gone.
    public func closeSession() {
        session?.disconnect()
        stopAdvertising()
        stopBrowsing()
        connectedPeers = []
        discoveredPeers = []
        session = nil
    }
}

// MARK: - Helpers
private extension MultipeerSessionManager {
    static func peerName(_ name: String) -> String {
        var trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.utf8.count > 63 { trimmed.removeLast() }
        return trimmed.isEmpty ? "Player" : trimmed
    }
}

// MARK: - MCSessionDelegate
extension MultipeerSessionManager: MCSessionDelegate {
    nonisolated public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        nonisolated(unsafe) let peers = session.connectedPeers
        nonisolated(unsafe) let capturedPeer = peerID
        nonisolated(unsafe) let changedSession = session
        Task { @MainActor in
            // A connection already closed can still report late; only the current one speaks for the match.
            guard changedSession === self.session else { return }
            self.connectedPeers = peers
            self.onPeerStateChanged?(capturedPeer, state)
        }
    }

    nonisolated public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? PeerMessage.decode(from: data) else { return }
        nonisolated(unsafe) let capturedPeer = peerID
        Task { @MainActor in
            self.lastReceivedMessage = (capturedPeer, message)
            self.onMessageReceived?(capturedPeer, message)
        }
    }

    nonisolated public func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    nonisolated public func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    nonisolated public func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: (any Error)?
    ) {}
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MultipeerSessionManager: MCNearbyServiceBrowserDelegate {
    nonisolated public func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        nonisolated(unsafe) let capturedPeer = peerID
        Task { @MainActor in
            if !self.discoveredPeers.contains(capturedPeer) {
                self.discoveredPeers.append(capturedPeer)
            }
        }
    }

    nonisolated public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        nonisolated(unsafe) let capturedPeer = peerID
        Task { @MainActor in
            self.discoveredPeers.removeAll { $0 == capturedPeer }
        }
    }

    nonisolated public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: any Error) {
        let reason = error.localizedDescription
        Task { @MainActor in
            self.logger.error("Browsing didn't start: \(reason, privacy: .public)")
            self.isDiscoveryBlocked = true
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MultipeerSessionManager: MCNearbyServiceAdvertiserDelegate {
    nonisolated public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        nonisolated(unsafe) let handler = invitationHandler
        Task { @MainActor in
            let hasOpponent = !(self.session?.connectedPeers.isEmpty ?? true)
            handler(!hasOpponent, hasOpponent ? nil : self.session)
        }
    }

    nonisolated public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: any Error
    ) {
        let reason = error.localizedDescription
        Task { @MainActor in
            self.logger.error("Advertising didn't start: \(reason, privacy: .public)")
            self.isDiscoveryBlocked = true
        }
    }
}
#endif
