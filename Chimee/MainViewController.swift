
import UIKit
import SQLite

// protocol used for sending data back
protocol MenuDelegate: class {
    // editing
    func copyText()
    func pasteText()
    func clearText()
    // message
    func insertMessage(_ text: String)
}

class MainViewController: UIViewController, KeyboardDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, MenuDelegate {

    var docController: UIDocumentInteractionController!
    let minimumInputWindowSize = CGSize(width: 80, height: 150)
    let inputWindowSizeIncrement: CGFloat = 50
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // MARK:- Outlets
    @IBOutlet weak var inputWindow: UIMongolTextView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var keyboardContainer: KeyboardController!
    @IBOutlet weak var inputWindowHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputWindowWidthConstraint: NSLayoutConstraint!
    
    // MARK:- Actions
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        // start spinner
        spinner.frame = self.view.frame // center it
        spinner.startAnimating()
        
        
        let message = inputWindow.text
        
        let image = imageFromTextView(inputWindow)
        
        
        // Create a URL
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory() + "MiniiChimee.png")
        
        
        // create image on a background thread, then share it
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            // save image to URL
            try? UIImagePNGRepresentation(image)?.write(to: imageURL, options: [.atomic])
            
            
            // update suggestion bar with those words
            DispatchQueue.main.async(execute: { () -> Void in
                
                // share the image
                self.clearText()
                self.clearKeyboard()
                self.docController.url = imageURL
                self.docController.presentOptionsMenu(from: sender, animated: true)
                
                self.spinner.stopAnimating()
                
            })
            
        })
        
        // save message to database history table
        saveMessageToHistory(message)
        
    }
    
    @IBAction func logoButtonTapped(_ sender: UIBarButtonItem) {
        
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
        if let savedText = UserDefaults.standard.string(forKey: UserDefaultsKey.lastMessage) {
            DispatchQueue.main.async {
                self.insertMessage(savedText)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)


        
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
    
    override func viewWillAppear(_ animated: Bool) {
        inputWindow.underlyingTextView.becomeFirstResponder()
    }
  

    // MARK: - KeyboardDelegate protocol
    
    func keyWasTapped(_ character: String) {
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
    
    func replaceCurrentWordWith(_ replacementWord: String) {
        inputWindow.replaceWordAtCursorWith(replacementWord)
    }
    
    func keyNewKeyboardChosen(_ type: KeyboardType) {
        // Do nothing
        // Keyboard Controller already handles keyboard switches
    }
    
    // MARK: - Other
    
    fileprivate func increaseInputWindowSizeIfNeeded() {
        
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
    
    
    fileprivate func decreaseInputWindowSizeIfNeeded() {
        
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
    
    func imageFromTextView(_ textView: UIMongolTextView) -> UIImage {
        
        // make a copy of the text view with the same size and text attributes
        let textViewCopy = UIMongolTextView(frame: textView.frame)
        textViewCopy.attributedText = textView.attributedText
        
        // resize if contentView is larger than the frame
        if textView.contentSize.width > textView.frame.width {
            textViewCopy.frame = CGRect(origin: CGPoint.zero, size: textView.contentSize)
        }
        
        // draw the text view to an image
        UIGraphicsBeginImageContextWithOptions(textViewCopy.bounds.size, false, UIScreen.main.scale)
        textViewCopy.drawHierarchy(in: textViewCopy.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "copyMenuSegue" {
            
            let popoverViewController = segue.destination as! CopyMenuViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.popoverPresentationController!.delegate = self
            popoverViewController.delegate = self
            
        } else if segue.identifier == "favoriteSegue" {
            
            let favoriteViewController = segue.destination as! FavoriteViewController
            
            favoriteViewController.currentMessage = inputWindow.text
            favoriteViewController.delegate = self
            
        }
    }
    
    func willResignActive() {
        
        // save the current text
        let defaults = UserDefaults.standard
        defaults.set(inputWindow.text, forKey: UserDefaultsKey.lastMessage)
        
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
    
    func saveMessageToHistory(_ message: String) {
        
        // do in background
        guard message.characters.count > 0 else {
            return
        }
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            
            do {
                
                _ = try HistoryDataHelper.insertMessage(message)
                //self.messages = try FavoriteDataHelper.findAll()
                
            } catch _ {
                print("message update failed")
            }
            

            
        })
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate method
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        
        // Force popover style
        return UIModalPresentationStyle.none
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
            UIPasteboard.general.string = selectedText
            
        } else { // copy everything
            
            // add unicode text to the pasteboard
            UIPasteboard.general.string = inputWindow.text
        }
        
        // tell user about problems with Unicode text
        // TODO: don't tell them every time forever
        showUnicodeNotification()
    }
    
    func pasteText() {
        if let myString = UIPasteboard.general.string {
            inputWindow.insertMongolText(myString)
        }
    }
    
    func clearText() {
        
        inputWindow.text = ""
        inputWindowWidthConstraint.constant = minimumInputWindowSize.width
        inputWindowHeightConstraint.constant = minimumInputWindowSize.height
    }
    
    func insertMessage(_ text: String) {
        inputWindow.insertMongolText(text)
        increaseInputWindowSizeIfNeeded()
        
        
    }

}


