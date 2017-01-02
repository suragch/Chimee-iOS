import UIKit
import SQLite

// View Controllers must adapt this protocol
protocol KeyboardDelegate: class {
    func keyWasTapped(_ character: String)
    func keyBackspace()
    func keyNewKeyboardChosen(_ type: KeyboardType)
    func charBeforeCursor() -> String?
    func oneMongolWordBeforeCursor() -> String?
    func twoMongolWordsBeforeCursor() -> (String?, String?)
    func replaceCurrentWordWith(_ replacementWord: String)
}

enum KeyboardType: Int {
    case qwerty
    case aeiou
    case english
    case cyrillic
    
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
    fileprivate let cellReuseIdentifier = "cell"
    fileprivate var suggestedWords: [String] = []
    let suggestionBarBackgroundColor = UIColor.clear
    
    // Mongol 
    let renderer = MongolUnicodeRenderer.sharedInstance
    fileprivate let mongolComma = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_COMMA).toString()
    fileprivate let mongolFullStop = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_FULL_STOP).toString()
    fileprivate let nnbs = ScalarString(MongolUnicodeRenderer.Uni.NNBS).toString()
    
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
        suggestionBarTable!.register(SuggestionBarTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        suggestionBarTable!.delegate = self
        suggestionBarTable!.dataSource = self
        suggestionBarTable?.tableFooterView = UIView()
        self.addSubview(suggestionBarTable!)
        
        
        
        // load keyboard
        setupNewKeyboard()
        
        
    }
    
    
    fileprivate func setupNewKeyboard() {
        // Keyboard
        let defaults = UserDefaults.standard
        let savedKeyboardType = KeyboardType(rawValue: defaults.integer(forKey: UserDefaultsKey.mostRecentKeyboard)) ?? KeyboardType.aeiou
        
        let renderedAeiou = renderer.unicodeToGlyphs(KeyboardType.AeiouName)
        let renderedQwerty = renderer.unicodeToGlyphs(KeyboardType.QwertyName)

        
        switch savedKeyboardType {
        case KeyboardType.aeiou:
            
            if aeiouKeyboard == nil {
                aeiouKeyboard = AeiouKeyboard(frame: self.bounds)
            }
            aeiouKeyboard?.delegate = self
            aeiouKeyboard?.otherAvailableKeyboards([
                (KeyboardType.english, KeyboardType.EnglishName),
                (KeyboardType.cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.qwerty, renderedQwerty)])
            currentKeyboard = aeiouKeyboard
            
            
        case KeyboardType.qwerty:
            
            if qwertyKeyboard == nil {
                qwertyKeyboard = QwertyKeyboard(frame: self.bounds)
            }
            qwertyKeyboard?.delegate = self
            qwertyKeyboard?.otherAvailableKeyboards([
                (KeyboardType.english, KeyboardType.EnglishName),
                (KeyboardType.cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.aeiou, renderedAeiou)])
            currentKeyboard = qwertyKeyboard
            
        case KeyboardType.english:
            
            if englishKeyboard == nil {
                englishKeyboard = EnglishKeyboard(frame: self.bounds)
            }
            englishKeyboard?.delegate = self
            englishKeyboard?.otherAvailableKeyboards([
                (KeyboardType.cyrillic, KeyboardType.CyrillicName),
                (KeyboardType.aeiou, renderedAeiou),
                (KeyboardType.qwerty, renderedQwerty)])
            currentKeyboard = englishKeyboard
            
        case KeyboardType.cyrillic:
            
            if cyrillicKeyboard == nil {
                cyrillicKeyboard = CyrillicKeyboard(frame: self.bounds)
            }
            cyrillicKeyboard?.delegate = self
            cyrillicKeyboard?.otherAvailableKeyboards([
                (KeyboardType.english, KeyboardType.EnglishName),
                (KeyboardType.aeiou, renderedAeiou),
                (KeyboardType.qwerty, renderedQwerty)])
            currentKeyboard = cyrillicKeyboard

        }
        
        
        self.addSubview(currentKeyboard!)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let suggestionBarFrame = CGRect(origin: self.bounds.origin, size: CGSize(width: suggestionBarWidth, height: self.bounds.height))
        suggestionBarTable?.frame = suggestionBarFrame
        suggestionBarTable!.separatorInset = UIEdgeInsets.zero
        suggestionBarTable!.estimatedRowHeight = 44.0
        suggestionBarTable!.rowHeight = UITableViewAutomaticDimension
        suggestionBarTable?.backgroundColor = suggestionBarBackgroundColor
        
        let keyboardFrame = CGRect(x: suggestionBarWidth, y: 0, width: self.bounds.width - suggestionBarWidth, height: self.bounds.height)
        currentKeyboard?.frame = keyboardFrame
        
    }
    
    // MARK: - KeyboardDelegate protocol
    
    func keyWasTapped(_ character: String) {
        
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
    
    func replaceCurrentWordWith(_ replacementWord: String) {
        delegate?.replaceCurrentWordWith(replacementWord)
    }
    
    func charBeforeCursor() -> String? {
        return delegate?.charBeforeCursor()
    }
    
    func keyNewKeyboardChosen(_ type: KeyboardType) {
        
        // save new keyboard
        let defaults = UserDefaults.standard
        defaults.set(type.rawValue, forKey: UserDefaultsKey.mostRecentKeyboard)
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestedWords.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SuggestionBarTableViewCell = self.suggestionBarTable!.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! SuggestionBarTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        let renderedText = renderer.unicodeToGlyphs(self.suggestedWords[indexPath.row])
        cell.mongolLabel.text = renderedText
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    func updateDictionaryWithWord(_ word: String, previousWord: String?) {
        
        // do on background thread
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
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
                    _ = try UserDictionaryDataHelper.updateFollowingForWord(previous, withFollowingWord: word)
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
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            // lookup words in user dictionary that start with word before cursor
            var suggestionList: [String] = []
            do {
                suggestionList = try UserDictionaryDataHelper.findWordsBeginningWith(wordBeforeCursor)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            DispatchQueue.main.async(execute: { () -> Void in
                
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
        guard let suffixStart = first, suffixStart.hasPrefix(nnbs) else {
            return
        }

        
        // get word ending and gender
        var gender = WordGender.masculine
        var ending = WordEnding.nil
        if let previousWord = second {
            (gender, ending) = genderAndEndingFor(previousWord)
        }
        
                
        // query db and update suggestion bar
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            // lookup words in suffix list that start with word before cursor
            var suggestionList: [String] = []
            
            do {
                suggestionList = try SuffixListDataHelper.findSuffixesBeginningWith(suffixStart, withGender: gender, andEnding: ending)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.suggestedWords = suggestionList
                self.suggestionBarTable?.reloadData()
            })
            
        })
        
        
    }
    
    func genderAndEndingFor(_ word: String) -> (WordGender, WordEnding) {
        
        let scalarString = ScalarString(word)
        var gender = WordGender.neutral
        var ending = WordEnding.nil
        
        // determine gender
        if renderer.isMasculineWord(scalarString) {
            gender = WordGender.masculine
        } else if renderer.isFeminineWord(scalarString) {
            gender = WordGender.feminine
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
            ending = WordEnding.vowel
        } else if renderer.isConsonant(endingChar) {
            if endingChar == MongolUnicodeRenderer.Uni.NA {
                ending = WordEnding.n
            } else if renderer.isBGDRS(endingChar) {
                ending = WordEnding.bigDress
            } else {
                ending = WordEnding.otherConsonant
            }
        }
        
        return (gender, ending)
    }
    
    func updateSuggestionBarWithFollowingWordsOf(_ thisWord: String) {

        
        // query db and update suggestion bar
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        backgroundQueue.async(execute: {
            
            // lookup words in user dictionary that start with word before cursor
            var suggestionList: [String] = []
            do {
                suggestionList = try UserDictionaryDataHelper.findFollowingWordsFor(thisWord)
            } catch _ {
                print("query for suggestions failed")
            }
            
            // update suggestion bar with those words
            DispatchQueue.main.async(execute: { () -> Void in
                
                self.suggestedWords = suggestionList
                self.suggestionBarTable?.reloadData()
            })
            
        })
    }
    
}































