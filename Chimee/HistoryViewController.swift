
import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mongolTableView: UIMongolTableView!
    
    weak var delegate: MenuDelegate? = nil
    
    let renderer = MongolUnicodeRenderer.sharedInstance
    let mongolFont = "ChimeeWhiteMirrored"
    let fontSize: CGFloat = 24
    
    let messagesPerBatch = 50
    var offset = 0
    var reachedEndOfMessages = false
    
    // Array of strings to display in table view cells
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: is it beter to let the parent/root set this?
        self.delegate = self.navigationController?.viewControllers[0] as! MainViewController
        
        // setup the table view from the IB reference
        mongolTableView.delegate = self
        mongolTableView.dataSource = self
        self.mongolTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.mongolTableView.tableFooterView = UIView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // load the favorites from the database
        loadMoreMessages()
    }
    
    
    // MARK: - Actions
    
    @IBAction func deleteAllButtonTapped(sender: UIBarButtonItem) {
        
        let title = "ᠤᠰᠠᠳᠬᠠᠬᠤ"
        let message = "ᠲᠠ ᠦᠨᠡᠭᠡᠷ ᠪᠦᠬᠦ ᠵᠠᠬᠢᠵ᠎ᠠ ᠶᠢ ᠤᠰᠠᠳᠬᠠᠬᠤ ᠤᠤ?"
        
        let actionOne = {
            () -> Void in
            
            // clear tableview
            self.messages = []
            self.mongolTableView.reloadData()
            self.offset = 0
            self.reachedEndOfMessages = true
            
            // clear database
            self.deleteAllHistoryMessagesFromDatabase()
        }
        
        showAlert(withTitle: title, message: message, numberOfButtons: 2, topButtonText: "ᠤᠰᠠᠳᠬᠠᠬᠤ", topButtonAction: actionOne, bottomButtonText: "ᠪᠤᠯᠢ", bottomButtonAction: nil, alertWidth: 170)
                
        
    }
    
    // MARK: - UITableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // set up the cells for the table view
        let cell: UITableViewCell = self.mongolTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        // TODO: use a custom UIMongolTableViewCell to render and choose font
        cell.layoutMargins = UIEdgeInsetsZero
        if let text = self.messages[indexPath.row].messageText {
            cell.textLabel?.text = renderer.unicodeToGlyphs(text)
            cell.textLabel?.font = UIFont(name: mongolFont, size: fontSize)
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let text = messages[indexPath.row].messageText {
            self.delegate?.insertMessage(text)
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            deleteHistoryMessageFromDatabase(messages[indexPath.row], indexPath: indexPath)
            
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "|"
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 0 {
            //print("reload")
            loadMoreMessages()
        }
    }
    
    // MARK: - Database
    
    func loadMoreMessages() {
        
        guard !self.reachedEndOfMessages else {
            return
        }
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            var thisBatchOfMessages: [Message]?
            let start = self.offset
            let end = self.offset + self.messagesPerBatch
            do {
                thisBatchOfMessages = try HistoryDataHelper.findRange(start..<end)
            } catch _ {
                print("query for history failed")
            }
            
            // update TableView with favorite messages
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let newMessages = thisBatchOfMessages {
                    
                    self.messages.appendContentsOf(newMessages)
                    self.mongolTableView.reloadData()
                    
                    if newMessages.count < self.messagesPerBatch {
                        self.reachedEndOfMessages = true
                    }
                    
                    self.offset += self.messagesPerBatch
                }
                
                
            })
            
            
        })
    }
    
    func deleteHistoryMessageFromDatabase(item: Message, indexPath: NSIndexPath) {
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            do {
                
                try HistoryDataHelper.delete(item)
                
            } catch _ {
                print("message delete failed")
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.messages.removeAtIndex(indexPath.row)
                self.mongolTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
            
        })
    }
    
    func deleteAllHistoryMessagesFromDatabase() {
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            do {
                
                try HistoryDataHelper.deleteAll()
                
            } catch _ {
                print("message delete failed")
            }
        })
    }
    
}






























