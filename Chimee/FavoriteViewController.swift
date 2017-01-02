
import UIKit

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mongolTableView: UIMongolTableView!
    
    weak var delegate: MenuDelegate? = nil
    
    let renderer = MongolUnicodeRenderer.sharedInstance
    let mongolFont = "ChimeeWhiteMirrored"
    let fontSize: CGFloat = 24
    
    // passed in from main view controller
    var currentMessage = ""
    
    // Array of strings to display in table view cells
    var messages: [Message]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // setup the table view from the IB reference
        mongolTableView.delegate = self
        mongolTableView.dataSource = self
        self.mongolTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.mongolTableView.tableFooterView = UIView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // load the favorites from the database
        loadFavorites()
        
    }
    
    func loadFavorites() {
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            // lookup words in user dictionary that start with word before cursor
            var favoritesList: [Message]?
            do {
                favoritesList = try FavoriteDataHelper.findAll()
            } catch _ {
                print("query for favorites failed")
            }
            
            // update TableView with favorite messages
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.messages = favoritesList
                self.mongolTableView?.reloadData()
                
            })
            
            
        })
    }
    

    
    // MARK: - Actions
    
    @IBAction func addFavoriteButtonTapped(_ sender: UIBarButtonItem) {
        
        guard currentMessage.characters.count > 0 else {
            // TODO: notify user that they have to write sth
            return
        }
        
        // add message to database
        addFavoriteMessageToDatabase(currentMessage)
        
    }
    
    @IBAction func historyButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    
    
    // MARK: - UITableView 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up the cells for the table view
        let cell: UITableViewCell = self.mongolTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        // TODO: use a custom UIMongolTableViewCell to render and choose font
        cell.layoutMargins = UIEdgeInsets.zero
        if let text = self.messages?[indexPath.row].messageText {
            cell.textLabel?.text = renderer.unicodeToGlyphs(text)
            cell.textLabel?.font = UIFont(name: mongolFont, size: fontSize)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let text = messages?[indexPath.row].messageText {
            self.delegate?.insertMessage(text)
            updateTimeForFavoriteMessage(text)
        }
        _ = self.navigationController?.popViewController(animated: true)
       
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if let message = messages?[indexPath.row] {
                deleteFavoriteMessageFromDatabase(message, indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "|"
    }
    

    
    // MARK: - Database
    
    func addFavoriteMessageToDatabase(_ message: String) {
        
        guard message.characters.count > 0 else {
            return
        }
    
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            do {
                
                    _ = try FavoriteDataHelper.insertMessage(message)
                    self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            
            // update TableView with favorite messages
            DispatchQueue.main.async(execute: { () -> Void in
                
                // insert row in table
                let indexPath = IndexPath(row: 0, section: 0)
                self.mongolTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.fade)
            })
            
        })
    
    }
    
    func deleteFavoriteMessageFromDatabase(_ item: Message, indexPath: IndexPath) {
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            do {
                
                try FavoriteDataHelper.delete(item)
                self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            
            // update TableView with favorite messages
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.mongolTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .fade)
            })
            
        })
    }
    
    func updateTimeForFavoriteMessage(_ messageText: String) {
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            do {
                
                try FavoriteDataHelper.updateTimeForFavorite(messageText)
                
            } catch _ {
                print("message update failed")
            }
            
        })
    }
}
