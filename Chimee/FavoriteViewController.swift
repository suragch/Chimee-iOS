
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
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            // lookup words in user dictionary that start with word before cursor
            var favoritesList: [Message]?
            do {
                favoritesList = try FavoriteDataHelper.findAll()
            } catch _ {
                print("query for favorites failed")
            }
            
            // update TableView with favorite messages
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.messages = favoritesList
                self.mongolTableView?.reloadData()
                
            })
            
            
        })
    }
    

    
    // MARK: - Actions
    
    @IBAction func addFavoriteButtonTapped(sender: UIBarButtonItem) {
        
        guard currentMessage.characters.count > 0 else {
            // TODO: notify user that they have to write sth
            return
        }
        
        // add message to database
        addFavoriteMessageToDatabase(currentMessage)
        
    }
    
    @IBAction func historyButtonTapped(sender: UIBarButtonItem) {
    }
    
    
    
    // MARK: - UITableView 
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages?.count ?? 0;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // set up the cells for the table view
        let cell: UITableViewCell = self.mongolTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        // TODO: use a custom UIMongolTableViewCell to render and choose font
        cell.layoutMargins = UIEdgeInsetsZero
        if let text = self.messages?[indexPath.row].messageText {
            cell.textLabel?.text = renderer.unicodeToGlyphs(text)
            cell.textLabel?.font = UIFont(name: mongolFont, size: fontSize)
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let text = messages?[indexPath.row].messageText {
            self.delegate?.insertMessage(text)
            updateTimeForFavoriteMessage(text)
        }
        self.navigationController?.popViewControllerAnimated(true)
       
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            if let message = messages?[indexPath.row] {
                deleteFavoriteMessageFromDatabase(message, indexPath: indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "|"
    }
    

    
    // MARK: - Database
    
    func addFavoriteMessageToDatabase(message: String) {
        
        guard message.characters.count > 0 else {
            return
        }
    
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            do {
                
                    try FavoriteDataHelper.insertMessage(message)
                    self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            
            // update TableView with favorite messages
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // insert row in table
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.mongolTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            })
            
        })
    
    }
    
    func deleteFavoriteMessageFromDatabase(item: Message, indexPath: NSIndexPath) {
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            do {
                
                try FavoriteDataHelper.delete(item)
                self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            
            // update TableView with favorite messages
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.mongolTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
            
        })
    }
    
    func updateTimeForFavoriteMessage(messageText: String) {
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            do {
                
                try FavoriteDataHelper.updateTimeForFavorite(messageText)
                
            } catch _ {
                print("message update failed")
            }
            
        })
    }
}
