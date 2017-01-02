import UIKit

class CopyMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mongolTableView: UIMongolTableView!
    
    weak var delegate: MenuDelegate? = nil

    let renderer = MongolUnicodeRenderer.sharedInstance
    let mongolFont = "ChimeeWhiteMirrored"
    let fontSize: CGFloat = 24
    
    // Array of strings to display in table view cells
    var items: [String] = ["ᠬᠠᠭᠤᠯᠬᠤ", "ᠨᠠᠭᠠᠬᠤ", "ᠠᠷᠢᠯᠭᠠᠬᠤ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the table view from the IB reference
        mongolTableView.delegate = self
        mongolTableView.dataSource = self
        self.mongolTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up the cells for the table view
        let cell: UITableViewCell = self.mongolTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        // TODO: use a custom UIMongolTableViewCell to render and choose font
        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.text = renderer.unicodeToGlyphs(self.items[indexPath.row])
        cell.textLabel?.font = UIFont(name: mongolFont, size: fontSize)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: nil)
        
        switch indexPath.row {
        case 0:
            delegate?.copyText()
        case 1:
            delegate?.pasteText()
        case 2:
            delegate?.clearText()
        default:
            
            print("chose an unsupported menu option")
        }
        
        
    }
}
