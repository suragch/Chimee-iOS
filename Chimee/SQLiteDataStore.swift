
import Swift
import SQLite

enum DataAccessError: Error {
    case datastore_Connection_Error
    case insert_Error
    case delete_Error
    case search_Error
    case nil_In_Data
}




class SQLiteDataStore {
    
    static let sharedInstance = SQLiteDataStore()
    let ChimeeDB: Connection?
    
    fileprivate init() {
        
        let filename = "db.sqlite"
        
        guard let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            ChimeeDB = nil
            return
        }
        
        let path = directoryURL.appendingPathComponent(filename).path
        
//        guard let path = directoryURL.appendingPathComponent(filename) else {
//            ChimeeDB = nil
//            return
//        }
        
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
            throw DataAccessError.datastore_Connection_Error
        }
    }
    
    func createMessageTables() throws {
        do {
            try FavoriteDataHelper.createTable()
            try HistoryDataHelper.createTable()
            // create any other future tables here
            
        } catch {
            throw DataAccessError.datastore_Connection_Error
        }
    }
}
