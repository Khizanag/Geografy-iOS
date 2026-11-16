#if !os(tvOS)
import MultipeerConnectivity

public struct PeerPlayer: Identifiable, Equatable {
    public let peerID: MCPeerID
    public var displayName: String
    public var isReady: Bool

    public var id: String { peerID.displayName }

    public init(peerID: MCPeerID, isReady: Bool = false) {
        self.peerID = peerID
        self.displayName = peerID.displayName
        self.isReady = isReady
    }

    public static func == (lhs: PeerPlayer, rhs: PeerPlayer) -> Bool {
        lhs.peerID == rhs.peerID && lhs.isReady == rhs.isReady
    }
}
#endif
