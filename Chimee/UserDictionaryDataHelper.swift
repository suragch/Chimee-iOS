import SQLite

protocol DataHelperProtocol {
    associatedtype T
    static func createTable() throws -> Void
    static func insert(_ item: T) throws -> Int64
    static func delete(_ item: T) throws -> Void
    static func findAll() throws -> [T]?
}

class UserDictionaryDataHelper: DataHelperProtocol {
    
    static let USERDICT_TABLE_NAME = "words"
    static let MAX_FOLLOWING_WORDS = 10
    static let MAX_QUERY_RESULTS = 20
    static let MIN_WORD_LENGTH = 2
    
    static let userDictionary = Table(USERDICT_TABLE_NAME)
    static let wordId = Expression<Int64>("_id")
    static let word = Expression<String>("word")
    static let frequency = Expression<Int64>("frequency")
    static let following = Expression<String>("following")
    
    typealias T = UserWord
    
    // MARK: - Methods
    
    static func createTable() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }

        
        do {
            let _ = try db.run( userDictionary.create(ifNotExists: true) {t in
                t.column(wordId, primaryKey: true)
                t.column(word, unique: true)
                t.column(frequency, defaultValue: 1)
                t.column(following, defaultValue: "")
                })
            
        } catch _ {
            // Error throw if table already exists
            print("database creation error")
            return
        }
        
    }
    
    static func listInfoForTable() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        do {
            
            let tableInfo = Array(try db.prepare("PRAGMA table_info(words)"))
            for line in tableInfo {
                print(line[1]!, terminator: " ")
            }
            print()
            
        } catch _ { }
    }
    
    static func insert(_ item: T) throws -> Int64 {
        
        // error checking
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        guard
            let wordToInsert = item.word,
            let frequencyToInsert = item.frequency,
            let followingToInsert = item.following else {
                
            throw DataAccessError.nil_In_Data
        }
        
        // do the insert
        let insert = userDictionary.insert(word <- wordToInsert, frequency <- frequencyToInsert, following <- followingToInsert)
        do {
            let rowId = try db.run(insert)
            guard rowId > 0 else {
                throw DataAccessError.insert_Error
            }
            return rowId
        } catch _ {
            throw DataAccessError.insert_Error
        }
    }
    
    static func delete (_ item: T) throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        if let id = item.wordId {
            let query = userDictionary.filter(wordId == id)
            do {
                let tmp = try db.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.delete_Error
                }
            } catch _ {
                throw DataAccessError.delete_Error
            }
        }
    }
    
    static func findWordForId(_ id: Int64) throws -> T? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        let query = userDictionary.filter(wordId == id)
        do {
            let items = try db.prepare(query)
            for item in items {
                return UserWord(wordId: item[wordId], word: item[word], frequency: item[frequency], following: item[following])
            }
        } catch _ {
            throw DataAccessError.search_Error
        }
        
        return nil // does this ever return nil after I added throw
        
    }
    
    static func findWord(_ wordToFind: String) throws -> T? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        let query = userDictionary.filter(word == wordToFind)
        do {
            let items = try db.prepare(query)
            for item in items {
                return UserWord(wordId: item[wordId], word: item[word], frequency: item[frequency], following: item[following])
            }
        } catch _ {
            throw DataAccessError.search_Error
        }
        
        return nil // does this ever return nil after I added throw
        
    }
    
    static func findWordsBeginningWith(_ mongolWord: String) throws -> [String] {
        
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        let searchPrefix = mongolWord + "%"
        let query = userDictionary.select(word)
            .filter(word.like(searchPrefix))
            .order(frequency.desc)
            .limit(MAX_QUERY_RESULTS)
        
        var results: [String] = []
        for row in try db.prepare(query) {
            results.append(row[word])
        }
        
        return results
        
    }
    
    static func findFollowingWordsFor(_ mongolWord: String) throws -> [String] {
        
        do {
            
            guard let userWord = try self.findWord(mongolWord) else {
                return []
            }
            guard let followingString = userWord.following else {
                return []
            }
            
            return followingString.characters.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: true).map(String.init)
        } catch _ {
            print("error finding following words")
        }
        
        return []
    }
    
    static func updateFrequencyForWord(_ wordToUpdate: String) throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        do {
            
            try db.transaction {
                let myWord = userDictionary.filter(word == wordToUpdate)
                if try db.run(myWord.update(frequency += 1)) > 0 {
                    //print("updated word frequency")
                } else {
                    _ = try db.run(userDictionary.insert(word <- wordToUpdate))
                    //print("inserted id: \(rowid)")
                }
            }
            
        } catch _ {
            print("some sort of error was thrown")
            throw DataAccessError.insert_Error // is this the best error to throw?
        }
        
    }
    
    static func updateFollowingForWord(_ wordToUpdate: String, withFollowingWord followingWord: String) throws -> Int {
        
        // error catching
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        guard !wordToUpdate.isEmpty && !followingWord.isEmpty else { return 0 }
        
        // Get following words string
        var userWord: T?
        do {
            userWord = try findWord(wordToUpdate)
        } catch _ {
            print("didn't find my word")
        }
        guard let id = userWord?.wordId else { return 0 } // TODO: insert word
        guard let followingListString = userWord?.following else { return 0 }
        
        // if followingWord is already first then quit
        if followingListString == followingWord
            || followingListString.hasPrefix("\(followingWord),") {
            
            return 0
        }
        
        // put followingWord first in the list
        let newListString = reorderFollowingString(followingListString, withWord: followingWord)
        var numberUpdated = 0
        
        // update the db
        do {
            
            try db.transaction {
                let myWord = userDictionary.filter(wordId == id)
                numberUpdated = try db.run(myWord.update(following <- newListString))
                if numberUpdated > 0 {
                    //print("updated word following")
                    
                } else {
                    _ = try db.run(userDictionary.insert(word <- wordToUpdate, following <- followingWord))
                    //print("inserted id: \(rowid)")
                }
            }
            
        } catch _ {
            print("some sort of error was thrown")
            throw DataAccessError.insert_Error // is this the best error to throw?
        }
        
        return numberUpdated
    }
    
    fileprivate static func reorderFollowingString(_ followingListString: String, withWord followingWord: String) -> String {
        
        if followingListString.isEmpty {
            return followingWord
        } else {
            let followingSplit = followingListString.characters.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: true).map(String.init)
            var newList = followingWord
            var counter = 0
            for item in followingSplit {
                if item != followingWord {
                    newList += (",\(item)")
                }
                counter += 1
                if counter >= MAX_FOLLOWING_WORDS {
                    break
                }
            }
            return newList
        }
    }
    
    static func findAll() throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let items = try db.prepare(userDictionary)
            for item in items {
                retArray.append(UserWord(wordId: item[wordId], word: item[word], frequency: item[frequency], following: item[following]))
            }
        } catch _ {
            throw DataAccessError.search_Error
        }
        
        return retArray
        
    }
}
