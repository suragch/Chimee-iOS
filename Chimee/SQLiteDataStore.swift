
import Swift
import SQLite

enum DataAccessError: ErrorType {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}




class SQLiteDataStore {
    
    static let sharedInstance = SQLiteDataStore()
    let ChimeeDB: Connection?
    
    private init() {
        
        let filename = "db.sqlite"
        
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            ChimeeDB = nil
            return
        }
        guard let path = directoryURL.URLByAppendingPathComponent(filename).path else {
            ChimeeDB = nil
            return
        }
        
        do {
            ChimeeDB = try Connection(path)
            
        } catch _ {
            ChimeeDB = nil
        }
        
    }
    
    func createDictionaryTables() throws {
        do {
            try UserDictionaryDataHelper.createTable()
            try SuffixListDataHelper.createTable()
            // create any other future tables here
            
            
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
    
    func createMessageTables() throws {
        do {
            try FavoriteDataHelper.createTable()
            try HistoryDataHelper.createTable()
            // create any other future tables here
            
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}