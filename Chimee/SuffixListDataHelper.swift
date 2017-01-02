import SQLite

class SuffixListDataHelper: DataHelperProtocol {
    
    static let SUFFIXLIST_TABLE_NAME = "suffixlist"
    
    static let suffixList = Table(SUFFIXLIST_TABLE_NAME)
    static let suffixId = Expression<Int64>("_id")
    static let suffix = Expression<String>("suffix")
    static let gender = Expression<Int64>("gender")
    static let endingType = Expression<Int64>("type")
    static let frequency = Expression<Int64>("frequency")
    
    typealias T = MongolSuffix
    
    static func createTable() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        // create table
        do {
            let _ = try db.run( suffixList.create(ifNotExists: false) {t in
                t.column(suffixId, primaryKey: true)
                t.column(suffix, unique: true)
                t.column(gender)
                t.column(endingType)
                t.column(frequency, defaultValue: 1)
                })
            
        } catch _ {
            // Error throw if table already exists
            // FIXME: This is relying on throwing an error every time. Perhaps not the best. http://stackoverflow.com/q/37185087
            
            return
        }
        
        // insert initial data
        do {
            try insertInitialData()
        } catch _ {
            print("Initialization error")
        }
    }
    
    static func insertInitialData() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        let data: [ (suffix: String, gender: WordGender, type: SuffixType) ] = [
            (" ᠶᠢᠨ", .neutral, .vowelOnly), // yin
            (" ᠤᠨ", .masculine, .consonantNonN), // on
            (" ᠦᠨ", .feminine, .consonantNonN), // un
            (" ᠤ", .masculine, .nOnly), //o
            (" ᠦ", .feminine, .nOnly), //u
            (" ᠢ", .neutral, .consonantsAll), //i
            (" ᠶᠢ", .neutral, .vowelOnly), //yi
            (" ᠳᠤ", .masculine, .notBigDress), //do
            (" ᠳᠦ", .feminine, .notBigDress), //du
            (" ᠲᠤ", .masculine, .bigDress), //to
            (" ᠲᠦ", .feminine, .bigDress), //tu
            (" ᠠᠴᠠ", .masculine, .all), //acha
            (" ᠡᠴᠡ", .feminine, .all), //eche
            (" ᠪᠠᠷ", .masculine, .vowelOnly), //bar
            (" ᠪᠡᠷ", .feminine, .vowelOnly), //ber
            (" ᠢᠶᠠᠷ", .masculine, .consonantsAll), //iyar
            (" ᠢᠶᠡᠷ", .feminine, .consonantsAll), //iyer
            (" ᠲᠠᠶ", .masculine, .all), //tai
            (" ᠲᠡᠶ", .feminine, .all), //tei
            (" ᠢᠶᠠᠨ", .masculine, .consonantsAll), //iyan
            (" ᠢᠶᠡᠨ", .feminine, .consonantsAll), //iyen
            (" ᠪᠠᠨ", .masculine, .vowelOnly), //ban
            (" ᠪᠡᠨ", .feminine, .vowelOnly), //ben
            (" ᠤᠤ", .masculine, .all), //oo
            (" ᠦᠦ", .feminine, .all), //uu
            (" ᠶᠤᠭᠠᠨ", .masculine, .all), //yogan
            (" ᠶᠦᠭᠡᠨ", .feminine, .all), //yugen
            (" ᠳᠠᠭᠠᠨ", .masculine, .notBigDress), //dagan
            (" ᠳᠡᠭᠡᠨ", .feminine, .notBigDress), //degen
            (" ᠲᠠᠭᠠᠨ", .masculine, .bigDress), //tagan
            (" ᠲᠡᠭᠡᠨ", .feminine, .bigDress), //tegen
            (" ᠠᠴᠠᠭᠠᠨ", .masculine, .all), //achagan
            (" ᠡᠴᠡᠭᠡᠨ", .feminine, .all), //echegen
            (" ᠲᠠᠶᠢᠭᠠᠨ", .masculine, .all), //taigan
            (" ᠲᠡᠶᠢᠭᠡᠨ", .feminine, .all), //teigen
            (" ᠤᠳ", .masculine, .all), //od
            (" ᠦᠳ", .feminine, .all), //ud
            (" ᠨᠤᠭᠤᠳ", .masculine, .all), //nogod
            (" ᠨᠦᠭᠦᠳ", .feminine, .all), //nugud
            (" ᠨᠠᠷ", .masculine, .all), //nar
            (" ᠨᠡᠷ", .feminine, .all) //ner
        ]
        
        do {
            
            // insert suffixes
            try db.transaction {
                for item in data {
                    let _ = try db.run(suffixList.insert(suffix <- item.suffix, gender <- item.gender.rawValue, endingType <- item.type.rawValue))
                }
            }
            
        } catch _ {
            print("insert error with suffix initialization")
            throw DataAccessError.insert_Error
        }
        
    }
    
    static func insert(_ item: T) throws -> Int64 {
        
        // error checking
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        guard
            let suffixToInsert = item.suffix,
            let genderToInsert = item.gender,
            let endingToInsert = item.endingType,
            let frequencyToInsert = item.frequency else {
                
                throw DataAccessError.nil_In_Data
        }
        
        // do the insert
        let insert = suffixList.insert(suffix <- suffixToInsert, gender <- genderToInsert, endingType <- endingToInsert, frequency <- frequencyToInsert)
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
    
    static func updateFrequencyForSuffix(_ suffixToUpdate: String) throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        do {
            
            try db.transaction {
                let mySuffix = suffixList.filter(suffix == suffixToUpdate)
                if try db.run(mySuffix.update(frequency += 1)) > 0 {
                    //print("updated suffix frequency")
                }
            }
            
        } catch _ {
            print("some sort of error was thrown")
            throw DataAccessError.insert_Error // is this the best error to throw?
        }
        
    }
    
    static func delete (_ item: T) throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        if let id = item.suffixId {
            let query = suffixList.filter(suffixId == id)
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
    
    static func findSuffixesBeginningWith(_ suffixStart: String, withGender gender: WordGender, andEnding ending: WordEnding) throws -> [String] {
        
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        
        let searchPrefix = suffixStart + "%"
        var query: Table!
        
       
        
        switch ending {
        case WordEnding.vowel:
            
            // filter gender
            if gender == WordGender.masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.feminine.rawValue &&
                    (self.endingType == SuffixType.vowelOnly.rawValue ||
                    self.endingType == SuffixType.notBigDress.rawValue ||
                    self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.masculine.rawValue &&
                    (self.endingType == SuffixType.vowelOnly.rawValue ||
                        self.endingType == SuffixType.notBigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.n:
            
            // filter gender
            if gender == WordGender.masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.feminine.rawValue &&
                    (self.endingType == SuffixType.nOnly.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.notBigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.masculine.rawValue &&
                    (self.endingType == SuffixType.nOnly.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.notBigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.bigDress:
            
            
            if gender == WordGender.masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.feminine.rawValue &&
                    (self.endingType == SuffixType.consonantNonN.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.bigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.masculine.rawValue &&
                    (self.endingType == SuffixType.consonantNonN.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.bigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.otherConsonant: // besides N or BGDRS
            
            
            if gender == WordGender.masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.feminine.rawValue &&
                    (self.endingType == SuffixType.consonantNonN.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.notBigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.masculine.rawValue &&
                    (self.endingType == SuffixType.consonantNonN.rawValue ||
                        self.endingType == SuffixType.consonantsAll.rawValue ||
                        self.endingType == SuffixType.notBigDress.rawValue ||
                        self.endingType == SuffixType.all.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.nil:

            query = suffixList.filter(suffix.like(searchPrefix) &&
                self.gender != WordGender.masculine.rawValue).order(frequency.desc)

        }
        
        var results: [String] = []
        for row in try db.prepare(query) {
            results.append(row[suffix])
        }
        
        return results
    }
    
    static func findAll() throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let items = try db.prepare(suffixList)
            for item in items {
                retArray.append(MongolSuffix(suffixId: item[suffixId], suffix: item[suffix], gender: item[gender], endingType: item[endingType], frequency: item[frequency]))
            }
        } catch _ {
            throw DataAccessError.search_Error
        }
        
        return retArray
        
    }

}
