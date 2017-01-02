

import UIKit

class AboutViewController: UIViewController {
    
    //let renderer = MongolUnicodeRenderer.sharedInstance
    
    @IBOutlet weak var chimeeVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get current version number
        let version =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as? String
        chimeeVersionLabel.text = "Chimee \(version ?? "")"
        
    }

}
