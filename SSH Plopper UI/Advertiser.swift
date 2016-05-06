import Cocoa
import MultipeerConnectivity

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate {

    let advertiser: MCNearbyServiceAdvertiser

    override init() {
        let peerId = MCPeerID(displayName: "minna")

        let serviceType = "ssh-key-service"

        advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)

        super.init()
    }

    func advertise() {
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        print("Started to listen")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("Received invitation from ", peerID)
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Error:", error)
    }
    
}
