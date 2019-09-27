
import Foundation
import SQLiteORM

public struct DB {
    public static let configDB: Database = {
        let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = ((dirs.first ?? "") as NSString).appendingPathComponent("config.db")
        return Database(.uri(path))
    }()

    private var dir: String

    public lazy var coreDB: Database = {
        let path = (dir as NSString).appendingPathComponent("core.db")
        return Database(.uri(path))
    }()

    public lazy var bufferDB: Database = {
        let path = (dir as NSString).appendingPathComponent("buffer.db")
        return Database(.uri(path))
    }()

    public lazy var dataDB: Database = {
        let path = (dir as NSString).appendingPathComponent("data.db")
        return Database(.uri(path))
    }()

    public lazy var historyDB: Database = {
        let path = (dir as NSString).appendingPathComponent("history.db")
        return Database(.uri(path))
    }()

    public lazy var searchDB: Database = {
        let path = (dir as NSString).appendingPathComponent("search.db")
        var db = Database(.uri(path))
        db.register(.sqliteorm, for: "enigma")
        return db
    }()

    public init(with id: String) {
        assert(id.count > 0, "invalid user id")
        let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        dir = ((dirs.first ?? "") as NSString).appendingPathComponent(id)
    }
}
