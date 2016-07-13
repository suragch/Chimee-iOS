
import UIKit
import SQLite

// protocol used for sending data back
protocol MenuDelegate: class {
    // editing
    func copyText()
    func pasteText()
    func clearText()
    // message
    func insertMessage(text: String)
}

class MainViewController: UIViewController, KeyboardDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, MenuDelegate {

    var docController: UIDocumentInteractionController!
    let minimumInputWindowSize = CGSize(width: 80, height: 150)
    let inputWindowSizeIncrement: CGFloat = 50
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    // MARK:- Outlets
    @IBOutlet weak var inputWindow: UIMongolTextView!
    
    @IBOutlet weak var topContainerView: UIView!
    
    @IBOutlet weak var keyboardContainer: KeyboardController!
    @IBOutlet weak var inputWindowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputWindowWidthConstraint: NSLayoutConstraint!
    
    @IBAction func testDeleteMe(sender: UIButton) {
        
        do {
            try UserDictionaryDataHelper.listInfoForTable()
        } catch _ { print("listInfoForTable error") }
        
        // print all the words in the user dictionary
        do {
            if let words = try UserDictionaryDataHelper.findAll() {
                for word in words {
                    print("\(word.wordId!) \(word.word!) \(word.frequency!) \(word.following!)")
                    
                }
            }
        } catch _ { print("find or delete error") }
    }

    // MARK:- Actions
    
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        
        // start spinner
        spinner.frame = self.view.frame // center it
        spinner.startAnimating()
        
        
        let message = inputWindow.text
        
        let image = imageFromTextView(inputWindow)
        
        
        // Create a URL
        let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingString("MiniiChimee.png"))
        
        
        // create image on a background thread, then share it
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            // save image to URL
            UIImagePNGRepresentation(image)?.writeToURL(imageURL, atomically: true)
            
            
            // update suggestion bar with those words
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // share the image
                self.clearText()
                self.clearKeyboard()
                self.docController.URL = imageURL
                self.docController.presentOptionsMenuFromBarButtonItem(sender, animated: true)
                
                self.spinner.stopAnimating()
                
            })
            
        })
        
        // save message to database history table
        saveMessageToHistory(message)
        
    }
    
    @IBAction func logoButtonTapped(sender: UIBarButtonItem) {
        
        // FIXME: This method is never called
        
    }
    
    
    // MARK:- Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup spinner
        spinner.backgroundColor = UIColor(white: 0, alpha: 0.2) // make bg darker for greater contrast
        self.view.addSubview(spinner)
        
        // inputWindow: get rid of space at beginning of textview
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        // Get any saved draft
        if let savedText = NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultsKey.lastMessage) {
            dispatch_async(dispatch_get_main_queue()) {
                self.insertMessage(savedText)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willResignActive), name: UIApplicationWillResignActiveNotification, object: nil)


        
        docController = UIDocumentInteractionController()
        
        // setup keyboard
        keyboardContainer.delegate = self
        inputWindow.underlyingTextView.inputView = UIView() // dummy view to prevent keyboard from showing
        inputWindow.underlyingTextView.becomeFirstResponder()
        

        // create message tables if they don't exist
        let dataStore = SQLiteDataStore.sharedInstance
        do {
            try dataStore.createMessageTables()
        } catch _ {}

        
    }
    
    override func viewWillAppear(animated: Bool) {
        inputWindow.underlyingTextView.becomeFirstResponder()
    }
  

    // MARK: - KeyboardDelegate protocol
    
    func keyWasTapped(character: String) {
        inputWindow.insertMongolText(character)
        increaseInputWindowSizeIfNeeded()
    }
    
    func keyBackspace() {
        inputWindow.deleteBackward()
        decreaseInputWindowSizeIfNeeded()
    }
    
    func charBeforeCursor() -> String? {
        return inputWindow.unicodeCharBeforeCursor()
    }
    
    func oneMongolWordBeforeCursor() -> String? {
        return inputWindow.oneMongolWordBeforeCursor()
    }
    
    func twoMongolWordsBeforeCursor() -> (String?, String?) {
        return inputWindow.twoMongolWordsBeforeCursor() 
    }
    
    func replaceCurrentWordWith(replacementWord: String) {
        inputWindow.replaceWordAtCursorWith(replacementWord)
    }
    
    func keyNewKeyboardChosen(type: KeyboardType) {
        // Do nothing
        // Keyboard Controller already handles keyboard switches
    }
    
    // MARK: - Other
    
    private func increaseInputWindowSizeIfNeeded() {
        
        if inputWindow.frame.size == topContainerView.frame.size {
            return
        }
        
        
        // width
        if inputWindow.contentSize.width > inputWindow.frame.width &&
            inputWindow.frame.width < topContainerView.frame.size.width {
            if inputWindow.contentSize.width > topContainerView.frame.size.width {
                inputWindowWidthConstraint.constant = topContainerView.frame.size.width
            } else {
                
                self.inputWindowWidthConstraint.constant = self.inputWindow.contentSize.width

            }
        }
        
        // height
        if inputWindow.contentSize.width > inputWindow.contentSize.height {
            if inputWindow.frame.height < topContainerView.frame.height {
                if inputWindow.frame.height + inputWindowSizeIncrement < topContainerView.frame.height {
                    // increase height by increment unit
                    inputWindowHeightConstraint.constant = inputWindow.frame.height + inputWindowSizeIncrement
                } else {
                    inputWindowHeightConstraint.constant = topContainerView.frame.height
                }
            }
        }
        
        
    }
    
    
    private func decreaseInputWindowSizeIfNeeded() {
        
        if inputWindow.frame.size == minimumInputWindowSize {
            return
        }
        
        // width
        if inputWindow.contentSize.width < inputWindow.frame.width &&
            inputWindow.frame.width > minimumInputWindowSize.width {
            //inputWindow.scrollEnabled = false
            if inputWindow.contentSize.width < minimumInputWindowSize.width {
                inputWindowWidthConstraint.constant = minimumInputWindowSize.width
            } else {
                inputWindowWidthConstraint.constant = inputWindow.contentSize.width
            }
        }
        
        // height
        if (2 * inputWindow.contentSize.width) <= inputWindow.contentSize.height && inputWindow.contentSize.width < topContainerView.frame.width {
            // got too high, make it shorter
            if minimumInputWindowSize.height < inputWindow.contentSize.height - inputWindowSizeIncrement {
                inputWindowHeightConstraint.constant = inputWindow.contentSize.height - inputWindowSizeIncrement
            } else {
                // Bump down to min height
                inputWindowHeightConstraint.constant = minimumInputWindowSize.height
            }
        }
    }
    
    func imageFromTextView(textView: UIMongolTextView) -> UIImage {
        
        // make a copy of the text view with the same size and text attributes
        let textViewCopy = UIMongolTextView(frame: textView.frame)
        textViewCopy.attributedText = textView.attributedText
        
        // resize if contentView is larger than the frame
        if textView.contentSize.width > textView.frame.width {
            textViewCopy.frame = CGRect(origin: CGPointZero, size: textView.contentSize)
        }
        
        // draw the text view to an image
        UIGraphicsBeginImageContextWithOptions(textViewCopy.bounds.size, false, UIScreen.mainScreen().scale)
        textViewCopy.drawViewHierarchyInRect(textViewCopy.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "copyMenuSegue" {
            
            let popoverViewController = segue.destinationViewController as! CopyMenuViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.delegate = self
            
        } else if segue.identifier == "favoriteSegue" {
            
            let favoriteViewController = segue.destinationViewController as! FavoriteViewController
            
            favoriteViewController.currentMessage = inputWindow.text
            favoriteViewController.delegate = self
            
        }
    }
    
    func willResignActive() {
        
        // save the current text
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(inputWindow.text, forKey: UserDefaultsKey.lastMessage)
        
    }
    
    func showUnicodeNotification() {
        
        let title = "ᠳᠤᠰ ᠪᠢᠴᠢᠯᠭᠡ ᠬᠠᠭᠤᠯᠠᠭᠳᠠᠪᠠ"
        let message = "ᠳᠤᠰ ᠪᠢᠴᠢᠯᠭᠡ ᠶᠢᠨ ᠶᠦᠨᠢᠺᠤᠳ᠋ ᠲᠡᠺᠧᠰᠲ ᠢ ᠭᠠᠷ ᠤᠳᠠᠰᠤᠨ ᠰᠢᠰᠲ᠋ᠧᠮ ᠦᠨ ᠨᠠᠭᠠᠬᠤ ᠰᠠᠮᠪᠠᠷ᠎ᠠ ᠳᠤ ᠬᠠᠭᠤᠯᠠᠭᠳᠠᠪᠠ᠃ ᠳᠠ ᠡᠭᠦᠨ ᠢ ᠪᠤᠰᠤᠳ APP ᠳᠤ ᠨᠠᠭᠠᠵᠤ ᠬᠡᠷᠡᠭᠯᠡᠵᠤ ᠪᠤᠯᠤᠨ᠎ᠠ᠃ ᠭᠡᠪᠡᠴᠦ ᠮᠤᠩᠭᠤᠯ ᠬᠡᠯᠡᠨ ᠦ ᠶᠦᠨᠢᠺᠤᠳ᠋ ᠤᠨ ᠪᠠᠷᠢᠮᠵᠢᠶ᠎ᠠ ᠨᠢᠭᠡᠳᠦᠭᠡᠳᠦᠢ ᠳᠤᠯᠠ ᠵᠠᠷᠢᠮ ᠰᠤᠹᠲ ᠪᠤᠷᠤᠭᠤ ᠦᠰᠦᠭ ᠢᠶᠡᠷ ᠢᠯᠡᠷᠡᠬᠦ ᠮᠠᠭᠠᠳ᠃"
        
        
        
        showAlert(withTitle: title, message: message, numberOfButtons: 1, topButtonText: "ᠮᠡᠳᠡᠯ᠎ᠡ", topButtonAction: nil, bottomButtonText: nil, bottomButtonAction: nil, alertWidth: 300)

        
        
    }
    
    func clearKeyboard() {
        self.keyboardContainer.clearKeyboard()
    }
    
    // MARK: - Database
    
    func saveMessageToHistory(message: String) {
        
        // do in background
        guard message.characters.count > 0 else {
            return
        }
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            
            do {
                
                try HistoryDataHelper.insertMessage(message)
                //self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            

            
        })
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate method
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        // Force popover style
        return UIModalPresentationStyle.None
    }
    
    // MARK: - Menu Delegate
    
    func copyText() {
        
        // check for empty input window
        guard inputWindow.text.characters.count > 0 else {
            //TODO:? show a notification that window is empty
            return
        }
        
        // copy (selected) text
        if let selectedText = inputWindow.selectedText() {
            
            // add unicode text to the pasteboard
            UIPasteboard.generalPasteboard().string = selectedText
            
        } else { // copy everything
            
            // add unicode text to the pasteboard
            UIPasteboard.generalPasteboard().string = inputWindow.text
        }
        
        // tell user about problems with Unicode text
        // TODO: don't tell them every time forever
        showUnicodeNotification()
    }
    
    func pasteText() {
        if let myString = UIPasteboard.generalPasteboard().string {
            inputWindow.insertMongolText(myString)
        }
    }
    
    func clearText() {
        
        inputWindow.text = ""
        inputWindowWidthConstraint.constant = minimumInputWindowSize.width
        inputWindowHeightConstraint.constant = minimumInputWindowSize.height
    }
    
    func insertMessage(text: String) {
        inputWindow.insertMongolText(text)
        increaseInputWindowSizeIfNeeded()
        
        
    }

}


