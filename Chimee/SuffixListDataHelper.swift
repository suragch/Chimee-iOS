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
            throw DataAccessError.Datastore_Connection_Error
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
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let data: [ (suffix: String, gender: WordGender, type: SuffixType) ] = [
            (" ᠶᠢᠨ", .Neutral, .VowelOnly), // yin
            (" ᠤᠨ", .Masculine, .ConsonantNonN), // on
            (" ᠦᠨ", .Feminine, .ConsonantNonN), // un
            (" ᠤ", .Masculine, .NOnly), //o
            (" ᠦ", .Feminine, .NOnly), //u
            (" ᠢ", .Neutral, .ConsonantsAll), //i
            (" ᠶᠢ", .Neutral, .VowelOnly), //yi
            (" ᠳᠤ", .Masculine, .NotBigDress), //do
            (" ᠳᠦ", .Feminine, .NotBigDress), //du
            (" ᠲᠤ", .Masculine, .BigDress), //to
            (" ᠲᠦ", .Feminine, .BigDress), //tu
            (" ᠠᠴᠠ", .Masculine, .All), //acha
            (" ᠡᠴᠡ", .Feminine, .All), //eche
            (" ᠪᠠᠷ", .Masculine, .VowelOnly), //bar
            (" ᠪᠡᠷ", .Feminine, .VowelOnly), //ber
            (" ᠢᠶᠠᠷ", .Masculine, .ConsonantsAll), //iyar
            (" ᠢᠶᠡᠷ", .Feminine, .ConsonantsAll), //iyer
            (" ᠲᠠᠶ", .Masculine, .All), //tai
            (" ᠲᠡᠶ", .Feminine, .All), //tei
            (" ᠢᠶᠠᠨ", .Masculine, .ConsonantsAll), //iyan
            (" ᠢᠶᠡᠨ", .Feminine, .ConsonantsAll), //iyen
            (" ᠪᠠᠨ", .Masculine, .VowelOnly), //ban
            (" ᠪᠡᠨ", .Feminine, .VowelOnly), //ben
            (" ᠤᠤ", .Masculine, .All), //oo
            (" ᠦᠦ", .Feminine, .All), //uu
            (" ᠶᠤᠭᠠᠨ", .Masculine, .All), //yogan
            (" ᠶᠦᠭᠡᠨ", .Feminine, .All), //yugen
            (" ᠳᠠᠭᠠᠨ", .Masculine, .NotBigDress), //dagan
            (" ᠳᠡᠭᠡᠨ", .Feminine, .NotBigDress), //degen
            (" ᠲᠠᠭᠠᠨ", .Masculine, .BigDress), //tagan
            (" ᠲᠡᠭᠡᠨ", .Feminine, .BigDress), //tegen
            (" ᠠᠴᠠᠭᠠᠨ", .Masculine, .All), //achagan
            (" ᠡᠴᠡᠭᠡᠨ", .Feminine, .All), //echegen
            (" ᠲᠠᠶᠢᠭᠠᠨ", .Masculine, .All), //taigan
            (" ᠲᠡᠶᠢᠭᠡᠨ", .Feminine, .All), //teigen
            (" ᠤᠳ", .Masculine, .All), //od
            (" ᠦᠳ", .Feminine, .All), //ud
            (" ᠨᠤᠭᠤᠳ", .Masculine, .All), //nogod
            (" ᠨᠦᠭᠦᠳ", .Feminine, .All), //nugud
            (" ᠨᠠᠷ", .Masculine, .All), //nar
            (" ᠨᠡᠷ", .Feminine, .All) //ner
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
            throw DataAccessError.Insert_Error
        }
        
    }
    
    static func insert(item: T) throws -> Int64 {
        
        // error checking
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        guard
            let suffixToInsert = item.suffix,
            let genderToInsert = item.gender,
            let endingToInsert = item.endingType,
            let frequencyToInsert = item.frequency else {
                
                throw DataAccessError.Nil_In_Data
        }
        
        // do the insert
        let insert = suffixList.insert(suffix <- suffixToInsert, gender <- genderToInsert, endingType <- endingToInsert, frequency <- frequencyToInsert)
        do {
            let rowId = try db.run(insert)
            guard rowId > 0 else {
                throw DataAccessError.Insert_Error
            }
            return rowId
        } catch _ {
            throw DataAccessError.Insert_Error
        }
    }
    
    static func updateFrequencyForSuffix(suffixToUpdate: String) throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
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
            throw DataAccessError.Insert_Error // is this the best error to throw?
        }
        
    }
    
    static func delete (item: T) throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.suffixId {
            let query = suffixList.filter(suffixId == id)
            do {
                let tmp = try db.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
    }
    
    static func findSuffixesBeginningWith(suffixStart: String, withGender gender: WordGender, andEnding ending: WordEnding) throws -> [String] {
        
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let searchPrefix = suffixStart + "%"
        var query: Table!
        
       
        
        switch ending {
        case WordEnding.Vowel:
            
            // filter gender
            if gender == WordGender.Masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Feminine.rawValue &&
                    (self.endingType == SuffixType.VowelOnly.rawValue ||
                    self.endingType == SuffixType.NotBigDress.rawValue ||
                    self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Masculine.rawValue &&
                    (self.endingType == SuffixType.VowelOnly.rawValue ||
                        self.endingType == SuffixType.NotBigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.N:
            
            // filter gender
            if gender == WordGender.Masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Feminine.rawValue &&
                    (self.endingType == SuffixType.NOnly.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.NotBigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Masculine.rawValue &&
                    (self.endingType == SuffixType.NOnly.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.NotBigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.BigDress:
            
            
            if gender == WordGender.Masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Feminine.rawValue &&
                    (self.endingType == SuffixType.ConsonantNonN.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.BigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Masculine.rawValue &&
                    (self.endingType == SuffixType.ConsonantNonN.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.BigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.OtherConsonant: // besides N or BGDRS
            
            
            if gender == WordGender.Masculine {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Feminine.rawValue &&
                    (self.endingType == SuffixType.ConsonantNonN.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.NotBigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            } else {
                query = suffixList.filter(suffix.like(searchPrefix) &&
                    self.gender != WordGender.Masculine.rawValue &&
                    (self.endingType == SuffixType.ConsonantNonN.rawValue ||
                        self.endingType == SuffixType.ConsonantsAll.rawValue ||
                        self.endingType == SuffixType.NotBigDress.rawValue ||
                        self.endingType == SuffixType.All.rawValue))
                    .order(frequency.desc)
            }
            
        case WordEnding.Nil:

            query = suffixList.filter(suffix.like(searchPrefix) &&
                self.gender != WordGender.Masculine.rawValue).order(frequency.desc)

        }
        
        var results: [String] = []
        for row in try db.prepare(query) {
            results.append(row[suffix])
        }
        
        return results
    }
    
    static func findAll() throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let items = try db.prepare(suffixList)
            for item in items {
                retArray.append(MongolSuffix(suffixId: item[suffixId], suffix: item[suffix], gender: item[gender], endingType: item[endingType], frequency: item[frequency]))
            }
        } catch _ {
            throw DataAccessError.Search_Error
        }
        
        return retArray
        
    }

}