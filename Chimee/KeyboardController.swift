import UIKit
import SQLite

// View Controllers must adapt this protocol
protocol KeyboardDelegate: class {
    func keyWasTapped(character: String)
    func keyBackspace()
    func keyNewKeyboardChosen(type: KeyboardType)
    func charBeforeCursor() -> String?
    func oneMongolWordBeforeCursor() -> String?
    func twoMongolWordsBeforeCursor() -> (String?, String?)
    func replaceCurrentWordWith(replacementWord: String)
}

enum KeyboardType: Int {
    case Qwerty
    case Aeiou
    case English
    case Cyrillic
    
    static let AeiouName = "ᠴᠠᠭᠠᠨ ᠲᠣᠯᠤᠭᠠᠢ"
    static let QwertyName = "ᠺᠤᠮᠫᠢᠦ᠋ᠲ᠋ᠧᠷ"
    static let EnglishName = "ABC"
    static let CyrillicName = "КИРИЛЛ"
}


class KeyboardController: UIView, KeyboardDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: KeyboardDelegate? // parent view controller
    
    // keyboards
    var qwertyKeyboard: QwertyKeyboard?
    var aeiouKeyboard: AeiouKeyboard?
    var englishKeyboard: EnglishKeyboard?
    var cyrillicKeyboard: CyrillicKeyboard?
    
    // suggestion bar
    var suggestionBarTable: UITableView?
    let suggestionBarWidth: CGFloat = 30
    private let cellReuseIdentifier = "cell"
    private var suggestedWords: [String] = []
    let suggestionBarBackgroundColor = UIColor.clearColor()
    
    // Mongol 
    let renderer = MongolUnicodeRenderer.sharedInstance
    private let mongolComma = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_COMMA).toString()
    private let mongolFullStop = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_FULL_STOP).toString()
    private let nnbs = ScalarString(MongolUnicodeRenderer.Uni.NNBS).toString()
    
    var currentKeyboard: UIView?
    var oldKeyboard: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        
        // dictionary
        setupDictionary()
        
        // Suggestion bar
        suggestionBarTable = UITableView()
        suggestionBarTable!.registerClass(SuggestionBarTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        suggestionBarTable!.delegate = self
        suggestionBarTable!.dataSource = self
        suggestionBarTable?.tableFooterView = UIView()
        self.addSubview(suggestionBarTable!)
        
        
        
        // load keyboard
        setupNewKeyboard()
        
        
    }
    
    
    private func setupNewKeyboard() {
        // Keyboard
        let defaults = NSUserDefaults.standardUserDefaults()
        let savedKeyboardType = KeyboardType(rawValue: defaults.integerForKey(UserDefaultsKey.mostRecentKeyboard)) ?? KeyboardType.Aeiou
        
        let renderedAeiou = renderer.unicodeToGlyphs(KeyboardType.AeiouName)
        let renderedQwerty = renderer.unicodeToGlyphs(KeyboardType.QwertyName)

        
        switch savedKeyboardType {
        case KeyboardType.Aeiou:
            
            if aeiouKeyboard == nil {
                aeiouKeyboard = AeiouKeyboard(frame: self.bounds)
            }
            aeiouKeyboard?.delegate = self
            aeiouKeyboard?.otherAvailableKeyboards([
                (KeyboardType.English, KeyboardType.EnglishName),
                (KeyboardType.Cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.Qwerty, renderedQwerty)])
            currentKeyboard = aeiouKeyboard
            
            
        case KeyboardType.Qwerty:
            
            if qwertyKeyboard == nil {
                qwertyKeyboard = QwertyKeyboard(frame: self.bounds)
            }
            qwertyKeyboard?.delegate = self
            qwertyKeyboard?.otherAvailableKeyboards([
                (KeyboardType.English, KeyboardType.EnglishName),
                (KeyboardType.Cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.Aeiou, renderedAeiou)])
            currentKeyboard = qwertyKeyboard
            
        case KeyboardType.English:
            
            if englishKeyboard == nil {
                englishKeyboard = EnglishKeyboard(frame: self.bounds)
            }
            englishKeyboard?.delegate = self
            englishKeyboard?.otherAvailableKeyboards([
                (KeyboardType.Cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.Aeiou, renderedAeiou),
                (KeyboardType.Qwerty, renderedQwerty)])
            currentKeyboard = englishKeyboard
            
        case KeyboardType.Cyrillic:
            
            if cyrillicKeyboard == nil {
                cyrillicKeyboard = CyrillicKeyboard(frame: self.bounds)
            }
            cyrillicKeyboard?.delegate = self
            cyrillicKeyboard?.otherAvailableKeyboards([
                (KeyboardType.English, KeyboardType.EnglishName),
                (KeyboardType.Aeiou, renderedAeiou),
                (KeyboardType.Qwerty, renderedQwerty)])
            currentKeyboard = cyrillicKeyboard

        }
        
        
        self.addSubview(currentKeyboard!)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let suggestionBarFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: suggestionBarWidth, height: self.bounds.height))
        suggestionBarTable?.frame = suggestionBarFrame
        suggestionBarTable!.separatorInset = UIEdgeInsetsZero
        suggestionBarTable!.estimatedRowHeight = 44.0
        suggestionBarTable!.rowHeight = UITableViewAutomaticDimension
        suggestionBarTable?.backgroundColor = suggestionBarBackgroundColor
        
        let keyboardFrame = CGRect(x: suggestionBarWidth, y: 0, width: self.bounds.width - suggestionBarWidth, height: self.bounds.height)
        currentKeyboard?.frame = keyboardFrame
        
    }
    
    // MARK: - KeyboardDelegate protocol
    
    func keyWasTapped(character: String) {
        
        // update dictionary with word
        if character == " " || character == "\n" {
            saveWord()
            
        } else if character == nnbs {
            
            // replace space with nnbs if there
            if delegate?.charBeforeCursor() == " " {
                delegate?.keyBackspace()
            } else {
                saveWord()
            }
            
            
        } else if character == "!" || character == "?" || character == mongolComma || character == mongolFullStop {
            
            // back up and add punctuation + space if follows space
            if delegate?.charBeforeCursor() == " " {
                delegate?.keyBackspace()
                delegate?.keyWasTapped(character + " ")
                return
            }
            saveWord()
        }
        
        
        delegate?.keyWasTapped(character)
        updateSuggestionBar()

    }
    

    
    func keyBackspace() {
        delegate?.keyBackspace()
        clearSuggestionBar()
    }
    
    func oneMongolWordBeforeCursor() -> String? {
        return delegate?.oneMongolWordBeforeCursor()
    }
    
    func twoMongolWordsBeforeCursor() -> (String?, String?) {
        
        return delegate?.twoMongolWordsBeforeCursor() ?? (nil, nil)
    }
    
    func replaceCurrentWordWith(replacementWord: String) {
        delegate?.replaceCurrentWordWith(replacementWord)
    }
    
    func charBeforeCursor() -> String? {
        return delegate?.charBeforeCursor()
    }
    
    func keyNewKeyboardChosen(type: KeyboardType) {
        
        // save new keyboard
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(type.rawValue, forKey: UserDefaultsKey.mostRecentKeyboard)
        
        // remove old keyboard
        currentKeyboard?.removeFromSuperview()
        
        // setup new keyboard
        setupNewKeyboard()
        
    }
    
    // MARK: - Other
    
    func clearKeyboard() {
        if currentKeyboard == aeiouKeyboard {
            aeiouKeyboard?.clearFvsKey()
        } else if currentKeyboard == qwertyKeyboard {
            qwertyKeyboard?.clearFvsKey()
        }
        
        clearSuggestionBar()
    }
    
    
    // MARK: - Table View
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestedWords.count
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:SuggestionBarTableViewCell = self.suggestionBarTable!.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! SuggestionBarTableViewCell
        cell.backgroundColor = UIColor.clearColor()
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
        let renderedText = renderer.unicodeToGlyphs(self.suggestedWords[indexPath.row])
        cell.mongolLabel.text = renderedText
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let chosenWord = self.suggestedWords[indexPath.row]
        
        // replace current word with cell text
        delegate?.replaceCurrentWordWith(chosenWord)
        
        // add a space (which updates the frequency and following position)
        self.keyWasTapped(" ")
        
        // clear table view
        clearSuggestionBar()
        
        // update table view with following words
        updateSuggestionBarWithFollowingWordsOf(chosenWord)
        

    }
    
    
    // MARK: - Database
    
    func setupDictionary() {
        // create dictionary if it doesn't exist
        // User dictionary
        let dataStore = SQLiteDataStore.sharedInstance
        do {
            try dataStore.createDictionaryTables()
        } catch _ {}
    }
    
    func saveWord() {
        
        // get the word before the cursor
        let twoWords = delegate?.twoMongolWordsBeforeCursor()
        
        // update as long as one word exists
        guard let firstWordBeforeCursor = twoWords?.0 else {
            return
        }
        
        if firstWordBeforeCursor.characters.count >= UserDictionaryDataHelper.MIN_WORD_LENGTH {
            updateDictionaryWithWord(firstWordBeforeCursor, previousWord: twoWords?.1)
        }
        
    }
    
    func updateDictionaryWithWord(word: String, previousWord: String?) {
        
        // do on background thread
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            // increment frequency (or insert if not in dictionary)
            do {
                if word.hasPrefix(self.nnbs) {
                    try SuffixListDataHelper.updateFrequencyForSuffix(word)
                } else {
                    try UserDictionaryDataHelper.updateFrequencyForWord(word)
                }
                
            } catch _ {
                print("frequency update failed")
            }
            
            // update following for previous word
            if let previous = previousWord {
                do {
                    try UserDictionaryDataHelper.updateFollowingForWord(previous, withFollowingWord: word)
                } catch _ {
                    print("following update failed")
                }
            }
        })
        
    }
    
    
    func updateSuggestionBar() {
        
        // get word before cursor
        guard let wordBeforeCursor = delegate?.oneMongolWordBeforeCursor() else {
            
            if delegate?.charBeforeCursor() == nnbs {
                updateSuggestionBarWithSuffixList()
            } else {
                clearSuggestionBar()
            }
            return
        }
        
        // check if it is a suffix
        if wordBeforeCursor.hasPrefix(nnbs) {
            updateSuggestionBarWithSuffixList()
            return
        }
        
        // query db and update suggestion bar
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            // lookup words in user dictionary that start with word before cursor
            var suggestionList: [String] = []
            do {
                suggestionList = try UserDictionaryDataHelper.findWordsBeginningWith(wordBeforeCursor)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.suggestedWords = suggestionList
                self.suggestionBarTable?.reloadData()
            })
            
        })
        
    }
    
    func clearSuggestionBar() {
        self.suggestedWords = []
        self.suggestionBarTable?.reloadData()
    }
    
    func updateSuggestionBarWithSuffixList() {
        
        // get current suffix start and previous word
        guard let (first, second) = delegate?.twoMongolWordsBeforeCursor() else {
            
            clearSuggestionBar()
            return
        }
        guard let suffixStart = first where suffixStart.hasPrefix(nnbs) else {
            return
        }

        
        // get word ending and gender
        var gender = WordGender.Masculine
        var ending = WordEnding.Nil
        if let previousWord = second {
            (gender, ending) = genderAndEndingFor(previousWord)
        }
        
                
        // query db and update suggestion bar
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            // lookup words in suffix list that start with word before cursor
            var suggestionList: [String] = []
            
            do {
                suggestionList = try SuffixListDataHelper.findSuffixesBeginningWith(suffixStart, withGender: gender, andEnding: ending)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.suggestedWords = suggestionList
                self.suggestionBarTable?.reloadData()
            })
            
        })
        
        
    }
    
    func genderAndEndingFor(word: String) -> (WordGender, WordEnding) {
        
        let scalarString = ScalarString(word)
        var gender = WordGender.Neutral
        var ending = WordEnding.Nil
        
        // determine gender
        if renderer.isMasculineWord(scalarString) {
            gender = WordGender.Masculine
        } else if renderer.isFeminineWord(scalarString) {
            gender = WordGender.Feminine
        }
        
        // determine ending
        let length = scalarString.length
        var endingChar = UInt32()
        if length > 0 {
            endingChar = scalarString.charAt(length - 1)
            if endingChar == MongolUnicodeRenderer.Uni.FVS1 ||
                endingChar == MongolUnicodeRenderer.Uni.FVS2 ||
                endingChar == MongolUnicodeRenderer.Uni.FVS3 {
                
                if length > 1 {
                    endingChar = scalarString.charAt(length - 2)
                } else {
                    endingChar = UInt32()
                }
            }
        }
        if renderer.isVowel(endingChar) {
            ending = WordEnding.Vowel
        } else if renderer.isConsonant(endingChar) {
            if endingChar == MongolUnicodeRenderer.Uni.NA {
                ending = WordEnding.N
            } else if renderer.isBGDRS(endingChar) {
                ending = WordEnding.BigDress
            } else {
                ending = WordEnding.OtherConsonant
            }
        }
        
        return (gender, ending)
    }
    
    func updateSuggestionBarWithFollowingWordsOf(thisWord: String) {

        
        // query db and update suggestion bar
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            // lookup words in user dictionary that start with word before cursor
            var suggestionList: [String] = []
            do {
                suggestionList = try UserDictionaryDataHelper.findFollowingWordsFor(thisWord)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.suggestedWords = suggestionList
                self.suggestionBarTable?.reloadData()
            })
            
        })
    }
    
}






























