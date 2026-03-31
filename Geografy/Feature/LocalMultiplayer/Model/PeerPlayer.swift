#if !os(tvOS)
import MultipeerConnectivity

struct PeerPlayer: Identifiable, Equatable {
    let peerID: MCPeerID
    var displayName: String
    var isReady: Bool

    var id: String { peerID.displayName }

    init(peerID: MCPeerID, isReady: Bool = false) {
        self.peerID = peerID
        self.displayName = peerID.displayName
        self.isReady = isReady
    }

    static func == (lhs: PeerPlayer, rhs: PeerPlayer) -> Bool {
        lhs.peerID == rhs.peerID && lhs.isReady == rhs.isReady
    }
}
#endif
