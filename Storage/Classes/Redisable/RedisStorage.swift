//
//  Table.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation

public protocol RedisStorable: Redisable where S.Key == C.Key, Key == S.Key {
    associatedtype S: Redisable
    associatedtype C: Redisable
    var storage: S { get set }
    var cache: C { get set }
    init(storage: S, cache: C)
}

// MARK: Redisable

extension RedisStorable {
    public mutating func set(_ key: S.Key, value: S.Value) -> Int {
        if let cacheValue = value as? C.Value {
            _ = cache.set(key, value: cacheValue)
        }
        return storage.set(key, value: value)
    }

    public mutating func set<T>(_ key: S.Key, value: T) -> Int where T: Equatable {
        if let oldValue = cache.get(key) as? T, oldValue == value {
            return 0
        }
        _ = cache.set(key, value: value)
        return storage.set(key, value: value)
    }

    public mutating func multiSet(_ keyValues: [S.Key: S.Value]) -> [S.Key: S.Value] {
        if let cacheKeyValues = keyValues as? [C.Key: C.Value] {
            _ = cache.multiSet(cacheKeyValues)
        }
        return storage.multiSet(keyValues)
    }

    public mutating func multiSet<T>(_ keyValues: [S.Key: T]) -> [S.Key: T] where T: Equatable {
        let _keys = [S.Key](keyValues.keys)
        let oldKeyValues = cache.multiGet(_keys) as? [S.Key: T] ?? [:]
        var newKeyValues = [S.Key: T]()
        for key in _keys {
            let oldValue = oldKeyValues[key]
            let value = keyValues[key]
            if oldValue == value {
                continue
            }
            newKeyValues[key] = value
        }
        _ = cache.multiSet(newKeyValues)
        return storage.multiSet(newKeyValues)
    }

    public mutating func get(_ key: S.Key) -> S.Value? {
        let cacheValue = cache.get(key)
        if let value = cacheValue as? S.Value { return value }
        let _value = storage.get(key)
        if let _cacheValue = _value as? C.Value { _ = cache.set(key, value: _cacheValue) }
        return _value
    }

    public mutating func multiGet(_ keys: [S.Key]) -> [S.Key: S.Value] {
        var keyValues = cache.multiGet(keys) as? [S.Key: S.Value] ?? [:]
        if keyValues.count == keys.count {
            return keyValues
        }

        let subKeys = Array(Set(keys).subtracting(Set(keyValues.keys)))
        let subKeyValues = storage.multiGet(subKeys)
        if let subCacheKeyValues = subKeyValues as? [C.Key: C.Value] {
            _ = cache.multiSet(subCacheKeyValues)
        }
        subKeyValues.forEach { keyValues[$0.key] = $0.value }
        return keyValues
    }

    public mutating func exists(_ key: S.Key) -> Bool {
        var r = cache.exists(key)
        if r { return r }
        r = storage.exists(key)
        if r, let v = storage.get(key), let nv = v as? C.Value {
            _ = cache.set(key, value: nv)
        }
        return r
    }

    public mutating func keys(lower: S.Key? = nil, upper: S.Key? = nil, limit: Int? = nil, bounds: Bounds, order desc: Bool) -> [S.Key] {
        let ormKeys = storage.keys(lower: lower, upper: upper, limit: limit, bounds: bounds, order: desc)
        let cacheKeys = cache.keys(lower: lower, upper: upper, limit: limit, bounds: bounds, order: desc)

        let delKeys = Array(Set(cacheKeys).subtracting(ormKeys))
        _ = cache.multiDel(delKeys)

        let addKeys = Array(Set(ormKeys).subtracting(cacheKeys))
        let addKeyValues = storage.multiGet(addKeys) as? [C.Key: C.Value] ?? [:]
        _ = cache.multiSet(addKeyValues)

        return ormKeys
    }

    public mutating func scan(lower: S.Key? = nil, upper: S.Key? = nil, limit: Int? = nil, bounds: Bounds, order desc: Bool) -> [(S.Key, S.Value)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit, bounds: bounds, order: desc)
        let keyValues = cache.multiGet(_keys) as? [S.Key: S.Value] ?? [:]
        var results = [(S.Key, S.Value)]()
        for key in _keys {
            if let value = keyValues[key] {
                results.append((key, value))
            }
        }
        return results
    }

    public mutating func round(_ center: S.Key?, lower: Int, upper: Int, order desc: Bool) -> [(S.Key, S.Value)] {
        let after = scan(lower: center, limit: upper, bounds: [.lower], order: desc)
        let front: [(S.Key, S.Value)] = center == nil ? [] : scan(upper: center, limit: lower, bounds: [], order: desc)
        return desc ? after + front : front + after
    }

    public mutating func del(_ key: S.Key) -> S.Value? {
        _ = cache.del(key)
        return storage.del(key)
    }

    public mutating func multiDel(_ keys: [S.Key]) -> [S.Key: S.Value] {
        _ = cache.multiDel(keys)
        return storage.multiDel(keys)
    }
}
