import SQLite

class HistoryDataHelper: DataHelperProtocol {
    
    static let HISTORY_MESSAGE_TABLE_NAME = "history"
    
    // history table
    static let historyMessageTable = Table(HISTORY_MESSAGE_TABLE_NAME)
    static let historyId = Expression<Int64>("_id")
    static let historyDate = Expression<Int64>("datetime")
    static let historyMessage = Expression<String>("message")
    
        
    typealias T = Message
    
    static func createTable() throws {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        // create table
        do {
            let _ = try db.run( historyMessageTable.create(ifNotExists: false) {t in
                t.column(historyId, primaryKey: true)
                t.column(historyDate)
                t.column(historyMessage)
                })
            
        } catch _ {
            // Error throw if table already exists
            // FIXME: This is relying on throwing an error every time. Perhaps not the best. http://stackoverflow.com/q/37185087
            
            return
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
        let insert = historyMessageTable.insert(historyDate <- dateToInsert, historyMessage <- messageToInsert)
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
        let insert = historyMessageTable.insert(historyDate <- dateToInsert, historyMessage <- messageToInsert)
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
    
    static func delete(item: T) throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.messageId {
            let query = historyMessageTable.filter(historyId == id)
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
    
    static func deleteAll() throws -> Void {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        do {
            _ = try db.run(historyMessageTable.delete())
        } catch _ {
            throw DataAccessError.Delete_Error
        }
    }
    
    static func findAll() throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let items = try db.prepare(historyMessageTable)
            for item in items {
                retArray.append(Message(messageId: item[historyId], dateTime: item[historyDate], messageText: item[historyMessage]))
            }
        } catch _ {
            throw DataAccessError.Search_Error
        }
        
        return retArray
        
    }
    
    static func findRange(rangeOfRows: Range<Int>) throws -> [T]? {
        guard let db = SQLiteDataStore.sharedInstance.ChimeeDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        do {
            let query = historyMessageTable.order(historyDate.desc).limit(rangeOfRows.endIndex - rangeOfRows.startIndex, offset: rangeOfRows.startIndex)
            let items = try db.prepare(query)
            for item in items {
                retArray.append(Message(messageId: item[historyId], dateTime: item[historyDate], messageText: item[historyMessage]))
            }
        } catch _ {
            throw DataAccessError.Search_Error
        }
        
        return retArray
        
    }
    
}