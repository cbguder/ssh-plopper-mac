import Cocoa
import MultipeerConnectivity

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    let advertiser: MCNearbyServiceAdvertiser
    let localPeerId : MCPeerID
    let session : MCSession

    override init() {
        localPeerId = MCPeerID(displayName: "balboa")
        let serviceType = "ssh-key-service"
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerId, discoveryInfo: nil, serviceType: serviceType)
        session = MCSession(peer: localPeerId, securityIdentity: nil, encryptionPreference: .Required)
        super.init()
    }

    func advertise() {
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        session.delegate = self;

        print("Started to listen")
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("Received invitation from ", peerID)
        let acceptedInvitation = true
        session.delegate = self;
        invitationHandler(acceptedInvitation, session)
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Error:", error)
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("Received data :" + data.description)
        let sshHelper = SSHHelper()
        sshHelper.addKey(data)
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        print("Did receive certificate")
        certificateHandler(true)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("did receive stream" + streamName)
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("did start receiving resource " + resourceName)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("change state" + peerID.displayName, state.rawValue)
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("did finish receiving resource " + resourceName)
    }
    
}
