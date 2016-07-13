
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
    case Neutral = 0
    case Masculine = 1
    case Feminine = 2
}

enum WordEnding {
    case Nil
    case Vowel
    case N
    case BigDress // b, g, d, r, s
    case OtherConsonant // not N or BGDRS
}

enum SuffixType: Int64 {
    case VowelOnly = 0
    case NOnly = 1
    case ConsonantNonN = 2
    case ConsonantsAll = 3
    case BigDress = 4
    case NotBigDress = 5
    case All = 6
}

struct UserDefaultsKey {
    static let mostRecentKeyboard = "mostRecentKeyboard"
    static let lastMessage = "lastMessage"
}














































