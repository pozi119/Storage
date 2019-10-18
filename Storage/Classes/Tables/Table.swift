//
//  Table.swift
//  Storage
//
//  Created by Valo on 2019/10/16.
//

import Foundation
import MMapKV
import SQLiteORM

extension Dictionary: Dictionariable where Key: Comparable {}
extension Dictionary: Redisable where Key: Comparable {}

extension MMapKV: Dictionariable where Key: Comparable {
    public var keys: Dictionary<Key, Value>.Keys {
        return dictionary.keys
    }
}

extension MMapKV: Redisable where Key: Comparable {}

open class Table<Cache: Redisable>: RedisStorable where Cache.Key == Orm.Key {
    public typealias S = Orm
    public typealias C = Cache

    public var storage: Orm

    public var cache: Cache

    public required init(storage: Orm, cache: Cache) {
        self.storage = storage
        self.cache = cache
    }
}
