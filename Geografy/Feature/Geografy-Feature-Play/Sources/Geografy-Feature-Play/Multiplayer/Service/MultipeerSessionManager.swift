#if !os(tvOS)
import MultipeerConnectivity

@MainActor
@Observable
public final class MultipeerSessionManager: NSObject, @unchecked Sendable {
    private(set) var connectedPeers: [MCPeerID] = []
    private(set) var discoveredPeers: [MCPeerID] = []
    private(set) var lastReceivedMessage: (peer: MCPeerID, message: PeerMessage)?

    private let serviceType = "geografy-quiz"
    private let myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    public var onMessageReceived: ((MCPeerID, PeerMessage) -> Void)?
    public var onPeerStateChanged: ((MCPeerID, MCSessionState) -> Void)?

    override init() {
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
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

    public func disconnect() {
        send(.disconnecting)
        session?.disconnect()
        stopAdvertising()
        stopBrowsing()
        connectedPeers = []
        discoveredPeers = []
        session = nil
    }
}

// MARK: - MCSessionDelegate
extension MultipeerSessionManager: MCSessionDelegate {
    nonisolated public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        nonisolated(unsafe) let peers = session.connectedPeers
        nonisolated(unsafe) let capturedPeer = peerID
        Task { @MainActor in
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
}
#endif
