//
//  Table.swift
//  Storage
//
//  Created by Valo on 2019/10/16.
//

import Foundation
import MMapKV
import Redisable
import SQLiteORM

extension Dictionary: Dictionariable where Key: Comparable {}
extension Dictionary: Redisable where Key: Comparable {}

extension MMKV: Dictionariable where Key: Comparable {
    public var keys: Dictionary<Key, Value>.Keys {
        return dictionary.keys
    }
}

extension MMKV: Redisable where Key: Comparable {}

open class Table<T: Codable, Cache: Redisable>: RedisStorable where Cache.Key == Orm<T>.Key {
    public typealias S = Orm
    public typealias C = Cache

    public var storage: Orm<T>

    public var cache: Cache

    public required init(storage: Orm<T>, cache: Cache) {
        self.storage = storage
        self.cache = cache
    }
}
