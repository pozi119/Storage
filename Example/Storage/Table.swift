//
//  Table.swift
//  Storage
//
//  Created by Valo on 2019/10/22.
//

import Foundation
import MMapKV
import SQLiteORM
import Storage_Redisable

public extension Orm.MMKVStroage {
    convenience init(_ name: String, db: Database, primaries: [String], uniques: [String] = []) {
        let dir = (db.path as NSString).deletingLastPathComponent
        let config = PlainConfig(T.self)
        config.primaries = primaries
        config.uniques = uniques
        let orm: Orm = Orm<T>(config: config, db: db, table: name)
        let mmkv: MMKV<String, T> = MMKV("com.valo.mmkv." + name, basedir: dir)
        self.init(store: orm, cache: mmkv)
    }
}

public struct Table {
    public static let db: Database = {
        let dirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = ((dirs.first ?? "") as NSString).appendingPathComponent("user.db")
        return Database(.uri(path))
    }()

    public static var user = Orm<User>.MMKVStroage("user", db: Table.db, primaries: ["id"])
}
