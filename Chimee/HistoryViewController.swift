
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
    
    @IBAction func deleteAllButtonTapped(_ sender: UIBarButtonItem) {
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up the cells for the table view
        let cell: UITableViewCell = self.mongolTableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        // TODO: use a custom UIMongolTableViewCell to render and choose font
        cell.layoutMargins = UIEdgeInsets.zero
        if let text = self.messages[indexPath.row].messageText {
            cell.textLabel?.text = renderer.unicodeToGlyphs(text)
            cell.textLabel?.font = UIFont(name: mongolFont, size: fontSize)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let text = messages[indexPath.row].messageText {
            self.delegate?.insertMessage(text)
        }
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            deleteHistoryMessageFromDatabase(messages[indexPath.row], indexPath: indexPath)
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "|"
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
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
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            var thisBatchOfMessages: [Message]?
            let start = self.offset
            let end = self.offset + self.messagesPerBatch
            do {
                thisBatchOfMessages = try HistoryDataHelper.findRange(start..<end)
            } catch _ {
                print("query for history failed")
            }
            
            // update TableView with favorite messages
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let newMessages = thisBatchOfMessages {
                    
                    self.messages.append(contentsOf: newMessages)
                    self.mongolTableView.reloadData()
                    
                    if newMessages.count < self.messagesPerBatch {
                        self.reachedEndOfMessages = true
                    }
                    
                    self.offset += self.messagesPerBatch
                }
                
                
            })
            
            
        })
    }
    
    func deleteHistoryMessageFromDatabase(_ item: Message, indexPath: IndexPath) {
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            do {
                
                try HistoryDataHelper.delete(item)
                
            } catch _ {
                print("message delete failed")
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.messages.remove(at: indexPath.row)
                self.mongolTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .fade)
            })
            
        })
    }
    
    func deleteAllHistoryMessagesFromDatabase() {
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            do {
                
                try HistoryDataHelper.deleteAll()
                
            } catch _ {
                print("message delete failed")
            }
        })
    }
    
}






























