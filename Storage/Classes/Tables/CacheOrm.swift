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

extension Dictionary: Dictionariable where Key: Comparable {}
extension Dictionary: Redisable where Key: Comparable {}

extension MMKV: Dictionariable where Key: Comparable {
    public var keys: Dictionary<Key, Value>.Keys {
        return dictionary.keys
    }
}

extension MMKV: Redisable where Key: Comparable {}

public final class MMKVOrm<T: Codable & Equatable>: RedisStorable {
    public typealias S = Orm<T>
    public typealias C = MMKV<Orm<T>.Key, T>

    public var storage: S

    public var cache: C

    public required init(storage: S, cache: C) {
        self.storage = storage
        self.cache = cache
    }
}

public final class DictionaryOrm<T: Codable & Equatable>: RedisStorable {
    public typealias S = Orm<T>
    public typealias C = Dictionary<Orm<T>.Key, T>

    public var storage: S

    public var cache: C

    public required init(storage: S, cache: C) {
        self.storage = storage
        self.cache = cache
    }
}
