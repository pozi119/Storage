//
//  Caching.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation
import MMapKV

public protocol Cacheable {
    associatedtype Key: Hashable & Comparable
    associatedtype Value
    typealias Element = (key: Key, value: Value)
    subscript(key: Key) -> Value? { get set }
    var cacheKeys: [Key] { get }
}

extension Dictionary: Cacheable where Key: Comparable {
    public typealias Key = Key
    public typealias Value = Value
    public var cacheKeys: [Key] { return [Key](keys) }
}

extension MMapKV: Cacheable {
    public var cacheKeys: [String] { return [String](dictionary.keys) }
}

public class EMCache<C: Cacheable> {
    private var cache: C

    init(_ cache: C) {
        self.cache = cache
    }

    // MARK: - set

    /// Set the value of the key.
    /// - Returns: -1 failure;  0 success ; 1 success and update
    public func set<T: Equatable>(_ key: C.Key, value: T) -> Int {
        guard let oldValue = cache[key] as? T else { return -1 }
        if oldValue == value { return 0 }
        guard let newValue = value as? C.Value else { return -1 }
        cache[key] = newValue
        return 1
    }

    /// Set the values related to the specified multiple keys
    /// - Returns: updated key-value pairs
    public func multiSet<T: Equatable>(_ keyValues: [C.Key: T]) -> [C.Key: Any] {
        var results: [C.Key: Any] = [:]
        for (key, value) in keyValues {
            if let oldValue = cache[key] as? T,
                oldValue != value,
                let newValue = value as? C.Value {
                cache[key] = newValue
                results[key] = value
            }
        }
        return results
    }

    // MARK: - get

    /// Get the value related to the specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    public func get(_ key: C.Key) -> Any? {
        return cache[key]
    }

    /// Get the values related to the specified multiple keys
    /// - Returns:  key-value pairs
    public func multiGet(_ keys: [C.Key]) -> [C.Key: Any] {
        var results: [C.Key: Any] = [:]
        keys.forEach { results[$0] = cache[$0] }
        return results
    }

    /// Verify if the specified key exists.
    public func exists(_ key: C.Key) -> Bool {
        return cache.cacheKeys.contains(key)
    }

    /// List keys in range (lower, upper], asc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many keys will be returned
    public func keys(lower: C.Key? = nil, upper: C.Key? = nil, limit: Int? = nil) -> [C.Key] {
        let keys = cache.cacheKeys.sorted()
        let filtered = keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && key > l }
            if let u = upper { r = r && key <= u }
            return r
        }
        if let l = limit, l < filtered.count {
            return [C.Key](filtered[0 ..< l])
        }
        return filtered
    }

    /// List keys in range [lower, upper), desc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many keys will be returned
    public func rkeys(lower: C.Key? = nil, upper: C.Key? = nil, limit: Int? = nil) -> [C.Key] {
        let keys = cache.cacheKeys.sorted().reversed()
        let filtered = keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && key >= l }
            if let u = upper { r = r && key < u }
            return r
        }
        if let l = limit, l < filtered.count {
            return [C.Key](filtered[0 ..< l])
        }
        return filtered
    }

    /// List key-value pairs with keys in range (lower, upper], asc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    public func scan(lower: C.Key? = nil, upper: C.Key? = nil, limit: Int? = nil) -> [(C.Key, Any)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit)
        var results: [(C.Key, Any)] = []
        _keys.forEach { results.append(($0, cache[$0]!)) }
        return results
    }

    /// List key-value pairs with keys in range [lower, upper), desc
    /// - Parameter upper: The upper bound(not included) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter lower: The lower bound(inclusive) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    public func rscan(lower: C.Key? = nil, upper: C.Key? = nil, limit: Int? = nil) -> [(C.Key, Any)] {
        let _keys = rkeys(lower: lower, upper: upper, limit: limit)
        var results: [(C.Key, Any)] = []
        _keys.forEach { results.append(($0, cache[$0]!)) }
        return results
    }

    /// List key-value pairs with keys in range (center - lower, center + upper)
    /// - Parameter upper: The upper bound(not included) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter lower: The lower bound(inclusive) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    public func round(_ center: C.Key, lower: Int, upper: Int, order desc: Bool = false) -> [(C.Key, Any)] {
        let lkeys = rkeys(upper: center, limit: lower)
        let ukeys = keys(lower: center, limit: upper)
        var _keys = (lkeys + ukeys).sorted()
        if desc { _keys = _keys.reversed() }
        var results: [(C.Key, Any)] = []
        _keys.forEach { results.append(($0, cache[$0]!)) }
        return results
    }

    // MARK: - del

    /// Delete specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    public func del(_ key: C.Key) -> Any? {
        let oldValue = cache[key]
        cache[key] = nil
        return oldValue
    }

    /// Delete specified multiple keys.
    /// - Returns: deleted key-value pairs
    public func multiDel(_ keys: [C.Key]) -> [C.Key: Any] {
        var results: [C.Key: Any] = [:]
        keys.forEach { key in
            results[key] = cache[key]
            cache[key] = nil
        }
        return results
    }
}
