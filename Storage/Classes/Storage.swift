//
//  Storage.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation
import MMapKV
import SQLiteORM

public protocol Storable: Redisable where Store.Key == Cache.Key, Key == Store.Key, Store.Value == Cache.Value, Cache.Value: Equatable {
    associatedtype Store: Redisable
    associatedtype Cache: Redisable
    var store: Store { get set }
    var cache: Cache { get set }
    init(store: Store, cache: Cache)
}

extension Storable {
    public mutating func set(_ key: Store.Key, value: Store.Value) -> Int {
        if let oldValue = cache.get(key), oldValue == value {
            return 0
        }
        let r = store.set(key, value: value)
        guard r >= 0 else { return r }
        _ = cache.set(key, value: value)
        return r
    }

    public mutating func multiSet(_ keyValues: [Store.Key: Store.Value]) -> [Store.Key: Store.Value] {
        let _keys = [Store.Key](keyValues.keys)
        let oldKeyValues = cache.multiGet(_keys)
        var newKeyValues = [Store.Key: Store.Value]()
        for key in _keys {
            let oldValue = oldKeyValues[key]
            let value = keyValues[key]
            if oldValue == value {
                continue
            }
            newKeyValues[key] = value
        }
        let r = store.multiSet(newKeyValues)
        guard r.count > 0 else { return r }
        _ = cache.multiSet(r)
        return r
    }

    public mutating func get(_ key: Store.Key) -> Store.Value? {
        if let value = cache.get(key) { return value }
        if let value = store.get(key) {
            _ = cache.set(key, value: value)
            return value
        }
        return nil
    }

    public mutating func multiGet(_ keys: [Store.Key]) -> [Store.Key: Store.Value] {
        var keyValues = cache.multiGet(keys)
        if keyValues.count == keys.count {
            return keyValues
        }

        let subKeys = Array(Set(keys).subtracting(Set(keyValues.keys)))
        let subKeyValues = store.multiGet(subKeys)
        if subKeyValues.count > 0 {
            _ = cache.multiSet(subKeyValues)
        }
        subKeyValues.forEach { keyValues[$0.key] = $0.value }
        return keyValues
    }

    public mutating func exists(_ key: Store.Key) -> Bool {
        let r = cache.exists(key)
        if r { return r }
        if let v = store.get(key) {
            _ = cache.set(key, value: v)
            return true
        }
        return false
    }

    public mutating func keys(lower: Store.Key? = nil, upper: Store.Key? = nil, limit: Int? = nil, bounds: Bounds = .all, desc: Bool = false) -> [Store.Key] {
        let storeKeys = store.keys(lower: lower, upper: upper, limit: limit, bounds: bounds, desc: desc)
        return storeKeys
    }

    public mutating func scan(lower: Store.Key? = nil, upper: Store.Key? = nil, limit: Int? = nil, bounds: Bounds = .all, desc: Bool = false) -> [(Store.Key, Store.Value)] {
        let storeKeys = store.keys(lower: lower, upper: upper, limit: limit, bounds: bounds, desc: desc)
        let cacheKeys = cache.keys(lower: lower, upper: upper, limit: limit, bounds: bounds, desc: desc)

        let delKeys = Array(Set(cacheKeys).subtracting(storeKeys))
        _ = cache.multiDel(delKeys)

        let addKeys = Array(Set(storeKeys).subtracting(cacheKeys))
        let addKeyValues = store.multiGet(addKeys)
        _ = cache.multiSet(addKeyValues)

        let keyValues = cache.multiGet(storeKeys)
        var results = [(Store.Key, Store.Value)]()
        for key in storeKeys {
            if let value = keyValues[key] {
                results.append((key, value))
            }
        }
        return results
    }

    public mutating func round(_ center: Store.Key?, lower: Int, upper: Int, desc: Bool) -> [(Store.Key, Store.Value)] {
        let after = scan(lower: center, limit: upper, bounds: [], desc: false)
        let front = center != nil ? scan(upper: center, limit: lower + 1, bounds: [.upper], desc: true).reversed() : []
        let array = front + after
        return desc ? array.reversed() : array
    }

    public mutating func del(_ key: Store.Key) -> Store.Value? {
        _ = cache.del(key)
        return store.del(key)
    }

    public mutating func multiDel(_ keys: [Store.Key]) -> [Store.Key: Store.Value] {
        _ = cache.multiDel(keys)
        return store.multiDel(keys)
    }
}

public extension Orm where T: Equatable {
    final class MMKVStroage: Storable {
        public typealias Store = Orm<T>
        public typealias Cache = MMKV<Orm<T>.Key, T>

        public var store: Store
        public var cache: Cache

        public required init(store: Store, cache: Cache) {
            self.store = store
            self.cache = cache
        }
    }

    final class DicStroage: Storable {
        public typealias Store = Orm<T>
        public typealias Cache = Dictionary<Orm<T>.Key, T>

        public var store: Store
        public var cache: Cache

        public required init(store: Store, cache: Cache) {
            self.store = store
            self.cache = cache
        }
    }
}

