import UIKit



class AeiouKeyboard: UIView, KeyboardKeyDelegate {
    
    weak var delegate: KeyboardDelegate? // probably the view or keyboard controller
    
    private let renderer = MongolUnicodeRenderer.sharedInstance
    private var punctuationOn = false
    private let nirugu = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_NIRUGU).toString()
    private let fvs1 = ScalarString(MongolUnicodeRenderer.Uni.FVS1).toString()
    private let fvs2 = ScalarString(MongolUnicodeRenderer.Uni.FVS2).toString()
    private let fvs3 = ScalarString(MongolUnicodeRenderer.Uni.FVS3).toString()
    private let mvs = ScalarString(MongolUnicodeRenderer.Uni.MVS).toString()
    private let mongolA = ScalarString(MongolUnicodeRenderer.Uni.A).toString()
    private let mongolE = ScalarString(MongolUnicodeRenderer.Uni.E).toString()
    private let period = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_FULL_STOP).toString()
    private let comma = ScalarString(MongolUnicodeRenderer.Uni.MONGOLIAN_COMMA).toString()
    
    // Keyboard Keys
    
    // Row 1
    private let keyA = KeyboardTextKey()
    private let keyE = KeyboardTextKey()
    private let keyI = KeyboardTextKey()
    private let keyO = KeyboardTextKey()
    private let keyU = KeyboardTextKey()
    
    // Row 2
    private let keyNA = KeyboardTextKey()
    private let keyBA = KeyboardTextKey()
    private let keyQA = KeyboardTextKey()
    private let keyGA = KeyboardTextKey()
    private let keyMA = KeyboardTextKey()
    private let keyLA = KeyboardTextKey()
    
    // Row 3
    private let keySA = KeyboardTextKey()
    private let keyDA = KeyboardTextKey()
    private let keyCHA = KeyboardTextKey()
    private let keyJA = KeyboardTextKey()
    private let keyYA = KeyboardTextKey()
    private let keyRA = KeyboardTextKey()
    
    // Row 4
    private let keyFVS = KeyboardFvsKey()
    private let keyMVS = KeyboardTextKey()
    private let keyWA = KeyboardTextKey()
    private let keyZA = KeyboardTextKey()
    private let keySuffix = KeyboardTextKey()
    private let keyBackspace = KeyboardImageKey()
    
    // Row 5
    private let keyKeyboard = KeyboardChooserKey()
    private let keyComma = KeyboardTextKey()
    private let keySpace = KeyboardImageKey()
    private let keyQuestion = KeyboardTextKey()
    private let keyReturn = KeyboardImageKey()
    
    
    
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    private func setup() {
        
        
        addSubviews()
        initializeNonChangingKeys()
        setMongolKeyStrings()
        assignDelegates()
        
    }
    
    private func addSubviews() {
        
        // TableView
        
        // Row 1
        self.addSubview(keyA)
        self.addSubview(keyE)
        self.addSubview(keyI)
        self.addSubview(keyO)
        self.addSubview(keyU)
        
        // Row 2
        self.addSubview(keyNA)
        self.addSubview(keyBA)
        self.addSubview(keyQA)
        self.addSubview(keyGA)
        self.addSubview(keyMA)
        self.addSubview(keyLA)
        
        // Row 3
        self.addSubview(keySA)
        self.addSubview(keyDA)
        self.addSubview(keyCHA)
        self.addSubview(keyJA)
        self.addSubview(keyYA)
        self.addSubview(keyRA)
        
        // Row 4
        self.addSubview(keyFVS)
        self.addSubview(keyMVS)
        self.addSubview(keyWA)
        self.addSubview(keyZA)
        self.addSubview(keySuffix)
        self.addSubview(keyBackspace)
        
        // Row 5
        self.addSubview(keyKeyboard)
        self.addSubview(keyComma)
        self.addSubview(keySpace)
        self.addSubview(keyQuestion)
        self.addSubview(keyReturn)
        
        
    }
    
    private func initializeNonChangingKeys() {
        
        
        // Row 4
        keyFVS.setStrings("", fvs2Top: "", fvs3Top: "", fvs1Bottom: "", fvs2Bottom: "", fvs3Bottom: "")
        keyMVS.primaryString = "\u{180E}" // MVS
        keyMVS.primaryStringDisplayOverride = "  " // na ma ga
        keyMVS.primaryStringFontSize = 11.0
        keyMVS.secondaryString = "\u{200D}" // ZWJ
        keyMVS.secondaryStringDisplayOverride = "" // TODO: make a better symbol
        
        keySuffix.primaryString = "\u{202F}" // NNBS
        keySuffix.primaryStringDisplayOverride = "  " // yi du un
        keySuffix.primaryStringFontSize = 11.0
        keyBackspace.image = UIImage(named: "backspace_dark")
        keyBackspace.keyType = KeyboardImageKey.KeyType.Backspace
        keyBackspace.repeatOnLongPress = true
        
        // Row 5
        keyKeyboard.image = UIImage(named: "keyboard_dark")
        keyComma.primaryString = "\u{1802}" // mongol comma
        keyComma.secondaryString = "\u{1803}" // mongol period
        keySpace.primaryString = " "
        keySpace.image = UIImage(named: "space_dark")
        keySpace.repeatOnLongPress = true
        keyQuestion.primaryString = "?"
        keyQuestion.secondaryString = "!"
        keyReturn.image = UIImage(named: "return_dark")
    }
    
    private func setMongolKeyStrings() {
        
        // Row 1
        keyA.primaryString = "ᠠ"
        keyA.secondaryString = "᠊"
        keyA.secondaryStringDisplayOverride = ""
        keyE.primaryString = "ᠡ"
        keyE.secondaryString = "ᠧ"
        keyI.primaryString = "ᠢ"
        keyI.secondaryString = ""
        keyO.primaryString = "ᠤ"
        keyO.primaryStringDisplayOverride = ""
        keyO.secondaryString = "ᠣ"
        keyU.primaryString = "ᠦ"
        keyU.primaryStringDisplayOverride = ""
        keyU.secondaryString = "ᠥ"
        
        // Row 2
        keyNA.primaryString = "ᠨ"
        keyNA.secondaryString = "ᠩ"
        keyBA.primaryString = "ᠪ"
        keyBA.secondaryString = "ᠫ"
        keyQA.primaryString = "ᠬ"
        keyQA.secondaryString = "ᠾ"
        keyGA.primaryString = "ᠭ"
        keyGA.secondaryString = "ᠺ"
        keyMA.primaryString = "ᠮ"
        keyMA.secondaryString = ""
        keyLA.primaryString = "ᠯ"
        keyLA.secondaryString = "ᡀ"
        
        // Row 3
        keySA.primaryString = "ᠰ"
        keySA.secondaryString = "ᠱ"
        keyDA.primaryString = "ᠳ"
        keyDA.secondaryString = "ᠲ"
        keyCHA.primaryString = "ᠴ"
        keyCHA.secondaryString = "ᡂ"
        keyJA.primaryString = "ᠵ"
        keyJA.secondaryString = "ᡁ"
        keyYA.primaryString = "ᠶ"
        keyYA.secondaryString = ""
        keyRA.primaryString = "ᠷ"
        keyRA.secondaryString = "ᠿ"
        
        // Row 4
        keyWA.primaryString = "ᠸ"
        keyWA.secondaryString = "ᠹ"
        keyZA.primaryString = "ᠽ"
        keyZA.secondaryString = "ᠼ"
        
    }
    
    private func setPunctuationKeyStrings() {
        
        // Row 1
        keyA.primaryString = "("
        keyA.secondaryString = "["
        keyE.primaryString = ")"
        keyE.secondaryString = "]"
        keyI.primaryString = "«"
        keyI.secondaryString = "<"
        keyO.primaryString = "»"
        keyO.secondaryString = ">"
        keyU.primaryString = "·"
        keyU.secondaryString = "᠁"
        
        // Row 2
        keyNA.primaryString = "1"
        keyNA.secondaryString = "᠑"
        keyBA.primaryString = "2"
        keyBA.secondaryString = "᠒"
        keyQA.primaryString = "3"
        keyQA.secondaryString = "᠓"
        keyGA.primaryString = "4"
        keyGA.secondaryString = "᠔"
        keyMA.primaryString = "5"
        keyMA.secondaryString = "᠕"
        keyLA.primaryString = "︱"
        keyLA.secondaryString = "᠀"
        
        // Row 3
        keySA.primaryString = "6"
        keySA.secondaryString = "᠖"
        keyDA.primaryString = "7"
        keyDA.secondaryString = "᠗"
        keyCHA.primaryString = "8"
        keyCHA.secondaryString = "᠘"
        keyJA.primaryString = "9"
        keyJA.secondaryString = "᠙"
        keyYA.primaryString = "0"
        keyYA.secondaryString = "᠐"
        keyRA.primaryString = "."
        keyRA.secondaryString = "᠅"
        
        // Row 4
        keyWA.primaryString = "⁈"
        keyWA.secondaryString = "᠄"
        keyZA.primaryString = "‼"
        keyZA.secondaryString = ";"
    }
    
    
    
    private func assignDelegates() {
        
        // Row 1
        keyA.delegate = self
        keyE.delegate = self
        keyI.delegate = self
        keyO.delegate = self
        keyU.delegate = self
        
        // Row 2
        keyNA.delegate = self
        keyBA.delegate = self
        keyQA.delegate = self
        keyGA.delegate = self
        keyMA.delegate = self
        keyLA.delegate = self
        
        // Row 3
        keySA.delegate = self
        keyDA.delegate = self
        keyCHA.delegate = self
        keyJA.delegate = self
        keyYA.delegate = self
        keyRA.delegate = self
        
        // Row 4
        keyFVS.delegate = self
        keyMVS.delegate = self
        keyWA.delegate = self
        keyZA.delegate = self
        keySuffix.delegate = self
        keyBackspace.delegate = self
        
        // Row 5
        keyKeyboard.delegate = self
        keyComma.delegate = self
        keySpace.delegate = self
        keyQuestion.delegate = self
        keyReturn.addTarget(self, action: #selector(keyReturnTapped), forControlEvents: UIControlEvents.TouchUpInside)

    }
    
    override func layoutSubviews() {
        // TODO: - should add autolayout constraints instead
        
        // |  A |  E | I | O  | U  |    Row 1
        // | N | B | Q | G | M | L |    Row 2
        // | S | D | Ch| J | Y | R |    Row 3
        // |fvs|mvs| W | Z |nbs|del|    Row 4
        // |123| . | space | ? |ret|    Row 5
        
        //let suggestionBarWidth: CGFloat = 30
        let numberOfRows: CGFloat = 5
        let keyUnitsInRow1: CGFloat = 5
        let keyUnitsInRow2to5: CGFloat = 6
        let rowHeight = self.bounds.height / numberOfRows
        let row1KeyUnitWidth = self.bounds.width / keyUnitsInRow1
        let row2to5KeyUnitWidth = self.bounds.width / keyUnitsInRow2to5
        
        // Row 1
        
        keyA.frame = CGRect(x: row1KeyUnitWidth*0, y: 0, width: row1KeyUnitWidth, height: rowHeight)
        keyE.frame = CGRect(x: row1KeyUnitWidth*1, y: 0, width: row1KeyUnitWidth, height: rowHeight)
        keyI.frame = CGRect(x: row1KeyUnitWidth*2, y: 0, width: row1KeyUnitWidth, height: rowHeight)
        keyO.frame = CGRect(x: row1KeyUnitWidth*3, y: 0, width: row1KeyUnitWidth, height: rowHeight)
        keyU.frame = CGRect(x: row1KeyUnitWidth*4, y: 0, width: row1KeyUnitWidth, height: rowHeight)
        
        // Row 2
        keyNA.frame = CGRect(x: row2to5KeyUnitWidth*0, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        keyBA.frame = CGRect(x: row2to5KeyUnitWidth*1, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        keyQA.frame = CGRect(x: row2to5KeyUnitWidth*2, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        keyGA.frame = CGRect(x: row2to5KeyUnitWidth*3, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        keyMA.frame = CGRect(x: row2to5KeyUnitWidth*4, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        keyLA.frame = CGRect(x: row2to5KeyUnitWidth*5, y: rowHeight, width: row2to5KeyUnitWidth, height: rowHeight)
        
        // Row 3
        keySA.frame = CGRect(x: row2to5KeyUnitWidth*0, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        keyDA.frame = CGRect(x: row2to5KeyUnitWidth*1, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        keyCHA.frame = CGRect(x: row2to5KeyUnitWidth*2, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        keyJA.frame = CGRect(x: row2to5KeyUnitWidth*3, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        keyYA.frame = CGRect(x: row2to5KeyUnitWidth*4, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        keyRA.frame = CGRect(x: row2to5KeyUnitWidth*5, y: rowHeight*2, width: row2to5KeyUnitWidth, height: rowHeight)
        
        // Row 4
        keyFVS.frame = CGRect(x: row2to5KeyUnitWidth*0, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        keyMVS.frame = CGRect(x: row2to5KeyUnitWidth*1, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        keyWA.frame = CGRect(x: row2to5KeyUnitWidth*2, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        keyZA.frame = CGRect(x: row2to5KeyUnitWidth*3, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        keySuffix.frame = CGRect(x: row2to5KeyUnitWidth*4, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        keyBackspace.frame = CGRect(x: row2to5KeyUnitWidth*5, y: rowHeight*3, width: row2to5KeyUnitWidth, height: rowHeight)
        
        // Row 5
        keyKeyboard.frame = CGRect(x: row2to5KeyUnitWidth*0, y: rowHeight*4, width: row2to5KeyUnitWidth, height: rowHeight)
        keyComma.frame = CGRect(x: row2to5KeyUnitWidth*1, y: rowHeight*4, width: row2to5KeyUnitWidth, height: rowHeight)
        keySpace.frame = CGRect(x: row2to5KeyUnitWidth*2, y: rowHeight*4, width: row2to5KeyUnitWidth*2, height: rowHeight)
        keyQuestion.frame = CGRect(x: row2to5KeyUnitWidth*4, y: rowHeight*4, width: row2to5KeyUnitWidth, height: rowHeight)
        keyReturn.frame = CGRect(x: row2to5KeyUnitWidth*5, y: rowHeight*4, width: row2to5KeyUnitWidth, height: rowHeight)
        
    }
    
    // MARK: - Other
    
    func otherAvailableKeyboards(keyboardTypeAndName: [(KeyboardType, String)]) {
        keyKeyboard.menuItems = keyboardTypeAndName
    }
    
    func updateFvsKey(previousChar: String?, currentChar: String) {
        
        // get the last character (previousChar is not necessarily a single char)
        var lastChar: UInt32 = 0
        if let previous = previousChar {
            for c in previous.unicodeScalars {
                lastChar = c.value
            }
        }
        
        // lookup the strings and update the key
        if renderer.isMongolian(lastChar) { // Medial or Final
            
            // Medial on top
            var fvs1Top = ""
            if let search = renderer.medialGlyphForUnicode(currentChar + fvs1) {
                fvs1Top = search
            }
            var fvs2Top = ""
            if let search = renderer.medialGlyphForUnicode(currentChar + fvs2) {
                fvs2Top = search
            }
            var fvs3Top = ""
            if let search = renderer.medialGlyphForUnicode(currentChar + fvs3) {
                fvs3Top = search
            }
            
            // Final on bottom
            var fvs1Bottom = ""
            if let search = renderer.finalGlyphForUnicode(currentChar + fvs1) {
                fvs1Bottom = search
            }
            var fvs2Bottom = ""
            if let search = renderer.finalGlyphForUnicode(currentChar + fvs2) {
                fvs2Bottom = search
            }
            var fvs3Bottom = ""
            if let search = renderer.finalGlyphForUnicode(currentChar + fvs3) {
                fvs3Bottom = search
            }
            
            keyFVS.setStrings(fvs1Top, fvs2Top: fvs2Top, fvs3Top: fvs3Top, fvs1Bottom: fvs1Bottom, fvs2Bottom: fvs2Bottom, fvs3Bottom: fvs3Bottom)
            
        } else { // Initial or Isolate
            
            // Initial on top
            var fvs1Top = ""
            if let search = renderer.initialGlyphForUnicode(currentChar + fvs1) {
                fvs1Top = search
            }
            var fvs2Top = ""
            if let search = renderer.initialGlyphForUnicode(currentChar + fvs2) {
                fvs2Top = search
            }
            var fvs3Top = ""
            if let search = renderer.initialGlyphForUnicode(currentChar + fvs3) {
                fvs3Top = search
            }
            
            // Isolate on bottom
            var fvs1Bottom = ""
            if let search = renderer.isolateGlyphForUnicode(currentChar + fvs1) {
                fvs1Bottom = search
            }
            var fvs2Bottom = ""
            if let search = renderer.isolateGlyphForUnicode(currentChar + fvs2) {
                fvs2Bottom = search
            }
            var fvs3Bottom = ""
            if let search = renderer.isolateGlyphForUnicode(currentChar + fvs3) {
                fvs3Bottom = search
            }
            
            keyFVS.setStrings(fvs1Top, fvs2Top: fvs2Top, fvs3Top: fvs3Top, fvs1Bottom: fvs1Bottom, fvs2Bottom: fvs2Bottom, fvs3Bottom: fvs3Bottom)
        }
    }
    
    //asdf
    // FIXME: Type Baina space Jirguga, highlight Jirguga, type something else.
    
    // MARK: - KeyboardKeyDelegate protocol
    
    func keyTextEntered(keyText: String) {
        
        if keyText == mvs {
            keyMvsTapped()
            return
        }
        
       
        let previousChar = self.delegate?.charBeforeCursor()
        updateFvsKey(previousChar, currentChar: keyText)
        
        self.delegate?.keyWasTapped(keyText)
    }
    
    func keyBackspaceTapped() {
        self.delegate?.keyBackspace()
        
        clearFvsKey()
    }
    
    func keyReturnTapped() {
        self.delegate?.keyWasTapped("\n")
        
        clearFvsKey()
    }
    
    func keyMvsTapped() {
        
        // add mvs + A or E (depending on word gender) + space
        if let word = delegate?.twoMongolWordsBeforeCursor().0 {
            
            if renderer.isFeminineWord(ScalarString(word)) {
                
                self.delegate?.keyWasTapped(mvs + mongolE)
                
            } else { // masculine
                
                // neutur words default to masculine (for q/g diferentialtion)
                // TODO: let user choose for masculine (or use database lookup)
                self.delegate?.keyWasTapped(mvs + mongolA)
            }
        }
        
        clearFvsKey()
    }
    
    func clearFvsKey() {
        keyFVS.setStrings("", fvs2Top: "", fvs3Top: "", fvs1Bottom: "", fvs2Bottom: "", fvs3Bottom: "")
    }
    
    func keyFvsTapped(fvs: String) {
        self.delegate?.keyWasTapped(fvs)
    }
    
    func keyKeyboardTapped() {
        
        // switch punctuation
        punctuationOn = !punctuationOn
        
        if punctuationOn {
            setPunctuationKeyStrings()
        } else {
            setMongolKeyStrings()
        }
        
        clearFvsKey()
    }
    
    // tell the view controller to switch keyboards
    func keyNewKeyboardChosen(type: KeyboardType) {
        delegate?.keyNewKeyboardChosen(type)
        clearFvsKey()
    }
    
}


