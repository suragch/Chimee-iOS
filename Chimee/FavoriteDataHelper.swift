import SQLite

class FavoriteDataHelper: DataHelperProtocol {
    
    static let FAVORITE_MESSAGE_TABLE_NAME = "favorite"
    
    // favorite table
    static let favoriteMessageTable = Table(FAVORITE_MESSAGE_TABLE_NAME)
    static let favoriteId = Expression<Int64>("_id")
    static let favoriteDate = Expression<Int64>("datetime")
    static let favoriteMessage = Expression<String>("message")
    
    typealias T = Message
    
    static func createTable() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        // create table
        do {
            let _ = try db.run( favoriteMessageTable.create(ifNotExists: false) {t in
                t.column(favoriteId, primaryKey: true)
                t.column(favoriteDate)
                t.column(favoriteMessage)
                })
            
                        
        } catch _ {
            // Error throw if table already exists
            // FIXME: This is relying on throwing an error every time. Perhaps not the best. http://stackoverflow.com/q/37185087
            
            //print("favorite database was already created")
            
            return
        }
        
        // insert initial data
        do {
            try insertInitialFavoritesData()
        } catch _ {
            print("Initialization error")
        }
    }
    
    
    
    static func insertInitialFavoritesData() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        // reverse order that they will appear in
        // TODO: get better mongol descriptions
        let data = [
            //"ᠲᠦᠯᠬᠢᠭᠡᠳ ᠠᠷᠢᠯᠭᠠᠬᠤ", // Swipe up to delete
            //"ᠳᠣᠶ᠋ᠢᠭᠠᠳ ᠣᠷᠤᠭᠤᠯᠬᠤ", //Tap to insert
            "ᠰᠠᠢᠨ ᠪᠠᠢᠨ᠎ᠠ ᠤᠤ?"
        ]
        
        do {
            
            // insert initial favorite messages
            try db.transaction {
                
                var extraSeconds = 0 // so that messages will be ordered by time
                for item in data {
                    let dateTime = Int64(NSDate().timeIntervalSince1970) + extraSeconds
                    let _ = try db.run(favoriteMessageTable.insert(favoriteDate <- dateTime, favoriteMessage <- item))
                    extraSeconds += 1
                }
            }
            
        } catch _ {
            print("insert error with favorite initialization")
            throw DataAccessError.Insert_Error
        }
        
    }
    
    static func insert(item: T) throws -> Int64 {
        
        // error checking
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        guard
            let dateToInsert = item.dateTime,
            let messageToInsert = item.messageText else {
                
                throw DataAccessError.Nil_In_Data
        }
        
        // do the insert
        let insert = favoriteMessageTable.insert(favoriteDate <- dateToInsert, favoriteMessage <- messageToInsert)
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
    
    static func insertMessage(messageToInsert: String) throws -> Int64 {
        
        // error checking
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
                
        // do the insert
        let dateToInsert = Int64(NSDate().timeIntervalSince1970)
        let insert = favoriteMessageTable.insert(favoriteDate <- dateToInsert, favoriteMessage <- messageToInsert)
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
    
    static func updateTimeForFavorite(messageText: String) throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        do {
            
            try db.transaction {
                let currentTime = Int64(NSDate().timeIntervalSince1970)
                let myMessage = favoriteMessageTable.filter(favoriteMessage == messageText)
                if try db.run(myMessage.update(favoriteDate <- currentTime)) > 0 {
                    //print("updated time")
                }
            }
            
        } catch _ {
            print("some sort of error was thrown")
            throw DataAccessError.Insert_Error // is this the best error to throw?
        }
        
    }
    
    static func delete(item: T) throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.messageId {
            let query = favoriteMessageTable.filter(favoriteId == id)
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
    
    
    static func findAll() throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let query = favoriteMessageTable.order(favoriteDate.desc)
            let items = try db.prepare(query)
            for item in items {
                retArray.append(Message(messageId: item[favoriteId], dateTime: item[favoriteDate], messageText: item[favoriteMessage]))
            }
        } catch _ {
            throw DataAccessError.Search_Error
        }
        
        return retArray
        
    }
    
}






















