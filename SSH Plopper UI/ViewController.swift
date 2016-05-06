import Cocoa
import MultipeerConnectivity


class ViewController: NSViewController, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    @IBOutlet weak var confirmationCodeField: NSTextField!
    @IBOutlet weak var peerIdField: NSTextField!
    
    let advertiser: MCNearbyServiceAdvertiser
    let localPeerId : MCPeerID
    let session : MCSession
    
    required init?(coder: NSCoder) {
        let hostName = NSHost.currentHost().localizedName
        localPeerId = MCPeerID(displayName: hostName!)
        print("Hostname is " + hostName!)
        let serviceType = "ssh-key-service"
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerId, discoveryInfo: nil, serviceType: serviceType)
        session = MCSession(peer: localPeerId, securityIdentity: nil, encryptionPreference: .Required)

        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        if (state == MCSessionState.Connected) {
            let randomNum = String(format: "%06d", arc4random_uniform(1000000))
            
            dispatch_async(dispatch_get_main_queue()) {
                print("in dispatch async")
                let dataNum = randomNum.dataUsingEncoding(NSUTF8StringEncoding)
                
                self.showNotification(randomNum)
                print("peer id is" + peerID.displayName)
                do {
                    try  session.sendData(dataNum!, toPeers: [peerID], withMode: .Reliable)
                } catch let error {
                    print ("Failed to send random code to client", error)
                }
//                self.dialogOKCancel("Ok?", text: randomNum)
                
                self.confirmationCodeField.stringValue = randomNum
                self.peerIdField.stringValue = peerID.displayName
            }
        }
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("did finish receiving resource " + resourceName)
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = text
        myPopup.informativeText = ""
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        //        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }
    
    func showNotification(text: String) -> Void {
        let notification = NSUserNotification()
        notification.title = "New SSH Plopper Connection"
        notification.informativeText = "Do you trust the number " + text
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }

}

