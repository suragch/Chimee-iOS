import XCTest
@testable import Chimee

class MongolTextStorageTests: XCTestCase {
    

    // TODO: add this to Mongol app componants
    
    // MARK: - replaceWordAtCursorWith
    
    func testReplaceWordAtCursorWith_endOfWord_newStringAndIndex() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 7 // ᠨᠢᠭᠡ ᠬᠣᠶ| ᠭᠤᠷᠪᠠ
        let replacementString = "ᠬᠣᠶᠠᠷ"
        
        // Act
        storage.replaceWordAtCursorWith(replacementString, atGlyphIndex: glyphIndex)
        storage.render() // updates glyph index
        let resultText = storage.unicode
        let expectedText = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let resultIndex = storage.glyphIndexForCursor
        let expectedIndex = 9 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ| ᠭᠤᠷᠪᠠ
        
        // Assert
        XCTAssertEqual(resultText, expectedText)
        XCTAssertEqual(resultIndex, expectedIndex)
    }
    
    func testReplaceWordAtCursorWith_midWord_newStringAndIndex() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 7 // ᠨᠢᠭᠡ ᠬᠣᠶ|ᠠᠷ ᠭᠤᠷᠪᠠ
        let replacementString = "ᠨᠢᠭᠡ"
        
        // Act
        storage.replaceWordAtCursorWith(replacementString, atGlyphIndex: glyphIndex)
        storage.render() // updates glyph index
        let resultText = storage.unicode
        let expectedText = "ᠨᠢᠭᠡ ᠨᠢᠭᠡ ᠭᠤᠷᠪᠠ"
        let resultIndex = storage.glyphIndexForCursor
        let expectedIndex = 7 // ᠨᠢᠭᠡ ᠨᠢᠭᠡ| ᠭᠤᠷᠪᠠ
        
        // Assert
        XCTAssertEqual(resultText, expectedText)
        XCTAssertEqual(resultIndex, expectedIndex)
    }
    
    func testReplaceWordAtCursorWith_beginningOfWord_insertNoReplace() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 4 // ᠨᠢᠭᠡ |ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        let replacementString = "ᠬᠣᠶᠠᠷ"
        
        // Act
        storage.replaceWordAtCursorWith(replacementString, atGlyphIndex: glyphIndex)
        storage.render() // updates glyph index
        let resultText = storage.unicode
        let expectedText = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let resultIndex = storage.glyphIndexForCursor
        let expectedIndex = 9 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ|ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        
        // Assert
        XCTAssertEqual(resultText, expectedText)
        XCTAssertEqual(resultIndex, expectedIndex)
    }
    
    func testReplaceWordAtCursorWith_beginningOfString_insertNoReplace() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "1234"
        let glyphIndex = 0 // |1234
        let replacementString = "ᠬᠣᠶᠠᠷ"
        
        // Act
        storage.replaceWordAtCursorWith(replacementString, atGlyphIndex: glyphIndex)
        storage.render() // updates glyph index
        let resultText = storage.unicode
        let expectedText = "ᠬᠣᠶᠠᠷ1234"
        let resultIndex = storage.glyphIndexForCursor
        let expectedIndex = 5 // ᠬᠣᠶᠠᠷ|1234
        
        // Assert
        XCTAssertEqual(resultText, expectedText)
        XCTAssertEqual(resultIndex, expectedIndex)
    }
    
    func testReplaceWordAtCursorWith_endOfString_insertNoReplace() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "1234"
        let glyphIndex = 4 // 1234|
        let replacementString = "ᠬᠣᠶᠠᠷ"
        
        // Act
        storage.replaceWordAtCursorWith(replacementString, atGlyphIndex: glyphIndex)
        storage.render() // updates glyph index
        let resultText = storage.unicode
        let expectedText = "1234ᠬᠣᠶᠠᠷ"
        let resultIndex = storage.glyphIndexForCursor
        let expectedIndex = 9 // 1234ᠬᠣᠶᠠᠷ|
        
        // Assert
        XCTAssertEqual(resultText, expectedText)
        XCTAssertEqual(resultIndex, expectedIndex)
    }
    
    // MARK: - unicodeOneWordBeforeCursor
    
    func testUnicodeOneWordBeforeCursor_emptyString_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = ""
        let glyphIndex = 0 // |
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = nil
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_oneWords_oneWords() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 9 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ| ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_midWord_wordFragment() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 13 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷ|ᠪᠠ
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = "ᠭᠤᠷ"
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_endOfString_oneWord() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 14 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ|
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = "ᠭᠤᠷᠪᠠ"
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_afterSpace_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 10 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ |ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = nil
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_afterFirstWord_firstWords() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 3 // ᠨᠢᠭᠡ| ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = "ᠨᠢᠭᠡ"
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_beginning_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 0 // |ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = nil
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    func testUnicodeOneWordBeforeCursor_nonMongol_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "This is some text."
        let glyphIndex = 9 // This is s|ome text.
        
        // Act
        let result = storage.unicodeOneWordBeforeCursor(glyphIndex)
        let expected: String? = nil
        
        // Assert
        XCTAssertEqual(result, expected)
    }
    
    // MARK: - unicodeTwoWordsBeforeCursor
    
    func testUnicodeTwoWordsBeforeCursor_emptyString_nilNil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = ""
        let glyphIndex = 0 // |
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = nil
        let expectedSecondWordBefore: String? = nil
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_twoWords_twoWords() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 9 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ| ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = "ᠬᠣᠶᠠᠷ"
        let expectedSecondWordBefore: String?  = "ᠨᠢᠭᠡ"
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_twoWordsMidWord_twoWords() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 13 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷ|ᠪᠠ
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = "ᠭᠤᠷ"
        let expectedSecondWordBefore: String?  = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_endOfString_twoWords() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 14 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ|
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = "ᠭᠤᠷᠪᠠ"
        let expectedSecondWordBefore: String?  = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_twoWordsSpace_nilNil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 10 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ |ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = nil
        let expectedSecondWordBefore: String? = nil
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_twoWordsNnbs_nnbsWord() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠢᠶᠠᠷ"
        let glyphIndex = 10 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ*|ᠢᠶᠠᠷ   (* = NNBS)
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = " " // nnbs
        let expectedSecondWordBefore: String? = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_wordNnbsWord_wordNnbsWord() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠢᠶᠠ"
        let glyphIndex = 13 // ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ*ᠢᠶᠠ| (* = NNBS)
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = " ᠢᠶᠠ" // *ᠢᠶᠠ
        let expectedSecondWordBefore: String? = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_oneWord_oneWord() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 3 // ᠨᠢᠭᠡ| ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = "ᠨᠢᠭᠡ"
        let expectedSecondWordBefore: String?  = nil
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_beginning_nilNil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphIndex = 0 // |ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = nil
        let expectedSecondWordBefore: String?  = nil
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    func testUnicodeTwoWordsBeforeCursor_nonMongol_nilNil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "This is some text."
        let glyphIndex = 9 // This is s|ome text.
        
        // Act
        let result = storage.unicodeTwoWordsBeforeCursor(glyphIndex)
        let expectedFirstWordBefore: String? = nil
        let expectedSecondWordBefore: String?  = nil
        
        // Assert
        XCTAssertEqual(result.0, expectedFirstWordBefore)
        XCTAssertEqual(result.1, expectedSecondWordBefore)
    }
    
    // MARK: - unicodeForGlyphRange
    
    func testUnicodeForGlyphRange_normal_string() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphRange = NSRange(location: 4, length: 5)
        
        // Act
        let result = storage.unicodeForGlyphRange(glyphRange)
        let expectedString: String? = "ᠬᠣᠶᠠᠷ"
        
        // Assert
        XCTAssertEqual(result, expectedString)
    }
    
    func testUnicodeForGlyphRange_noSelection_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = "ᠨᠢᠭᠡ ᠬᠣᠶᠠᠷ ᠭᠤᠷᠪᠠ"
        let glyphRange = NSRange(location: 4, length: 0)
        
        // Act
        let result = storage.unicodeForGlyphRange(glyphRange)
        let expectedString: String? = nil
        
        // Assert
        XCTAssertEqual(result, expectedString)
    }
    
    func testUnicodeForGlyphRange_emptyString_nil() {
        
        // Arrange
        let storage = MongolTextStorage()
        storage.unicode = ""
        let glyphRange = NSRange(location: 0, length: 0)
        
        // Act
        let result = storage.unicodeForGlyphRange(glyphRange)
        let expectedString: String? = nil
        
        // Assert
        XCTAssertEqual(result, expectedString)
    }
}
