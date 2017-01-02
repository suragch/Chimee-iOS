
import Swift

typealias UserWord = (
    wordId: Int64?,
    word: String?,
    frequency: Int64?,
    following: String?
)

typealias MongolSuffix = (
    suffixId: Int64?,
    suffix: String?,
    gender: Int64?,
    endingType: Int64?,
    frequency: Int64?
)

typealias Message = (
    messageId: Int64?,
    dateTime: Int64?,
    messageText: String?
)

enum WordGender: Int64 {
    case neutral = 0
    case masculine = 1
    case feminine = 2
}

enum WordEnding {
    case `nil`
    case vowel
    case n
    case bigDress // b, g, d, r, s
    case otherConsonant // not N or BGDRS
}

enum SuffixType: Int64 {
    case vowelOnly = 0
    case nOnly = 1
    case consonantNonN = 2
    case consonantsAll = 3
    case bigDress = 4
    case notBigDress = 5
    case all = 6
}

struct UserDefaultsKey {
    static let mostRecentKeyboard = "mostRecentKeyboard"
    static let lastMessage = "lastMessage"
}














































