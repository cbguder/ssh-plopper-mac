import Cocoa

class ViewController: NSViewController {

    let advertiser: Advertiser

    required init?(coder: NSCoder) {
        advertiser = Advertiser()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        advertiser.advertise()
    }

}

