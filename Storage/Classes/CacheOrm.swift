//
//  CacheOrm.swift
//  Storage
//
//  Created by Valo on 2019/10/16.
//

import Foundation
import MMapKV
import Redisable
import SQLiteORM

extension Dictionary: Dictionariable where Key: Comparable, Value: Equatable {}
extension Dictionary: Redisable where Key: Comparable, Value: Equatable {}

extension MMKV: Dictionariable where Key: Comparable, Value: Equatable {
    public var keys: Dictionary<Key, Value>.Keys {
        return dictionary.keys
    }
}

extension MMKV: Redisable where Key: Comparable, Value: Equatable {}

public final class MMKVOrm<T: Storable>: RedisStorable {
    public typealias Store = Orm<T>
    public typealias Cache = MMKV<Orm<T>.Key, T>

    public var store: Store
    public var cache: Cache

    public required init(store: Store, cache: Cache) {
        self.store = store
        self.cache = cache
    }
}

public final class DictionaryOrm<T: Storable>: RedisStorable {
    public typealias Store = Orm<T>
    public typealias Cache = Dictionary<Orm<T>.Key, T>

    public var store: Store
    public var cache: Cache

    public required init(store: Store, cache: Cache) {
        self.store = store
        self.cache = cache
    }
}
