//
//  DictionaryRedis.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation
import MMapKV
import SQLiteORM

public protocol Dictionariable {
    associatedtype Key: Hashable & Comparable
    associatedtype Value
    subscript(key: Key) -> Value? { get set }
    @inlinable var keys: Dictionary<Key, Value>.Keys { get }
}

extension Dictionariable {
    // MARK: - set

    public mutating func set<T: Equatable>(_ key: Key, value: T) -> Int {
        guard let oldValue = self[key] as? T else { return -1 }
        if oldValue == value { return 0 }
        guard let newValue = value as? Value else { return -1 }
        self[key] = newValue
        return 1
    }

    public mutating func multiSet<T: Equatable>(_ keyValues: [Key: T]) -> [Key: T] {
        var results: [Key: T] = [:]
        for (key, value) in keyValues {
            if let oldValue = self[key] as? T,
                oldValue != value,
                let newValue = value as? Value {
                self[key] = newValue
                results[key] = value
            }
        }
        return results
    }

    // MARK: - get

    public func get(_ key: Key) -> Any? {
        return self[key]
    }

    public func multiGet(_ keys: [Key]) -> [Key: Any] {
        var results: [Key: Any] = [:]
        keys.forEach { results[$0] = self[$0] }
        return results
    }

    public func exists(_ key: Key) -> Bool {
        return keys.contains(key)
    }

    public func keys(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds,
                     order desc: Bool = false) -> [Key] {
        let _keys = desc ? keys.sorted().reversed() : keys.sorted()
        let filtered = _keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && (bounds.contains(.lower) ? key >= l : key > l) }
            if let u = upper { r = r && (bounds.contains(.upper) ? key <= u : key < u) }
            return r
        }
        if let l = limit, l < filtered.count {
            return [Key](filtered[0 ..< l])
        }
        return filtered
    }

    public func scan(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds,
                     order desc: Bool = false) -> [(Key, Any)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit, bounds: bounds, order: desc)
        var results: [(Key, Any)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    public func round(_ center: Key?, lower: Int, upper: Int, order desc: Bool = false) -> [(Key, Any)] {
        var _keys = keys(lower: center, limit: upper + 1, bounds: [.lower], order: false)
        if center != nil {
            _keys += keys(upper: center, limit: lower + 1, bounds: [], order: false)
        }
        _keys = desc ? _keys.sorted().reversed() : _keys.sorted()
        if desc { _keys = _keys.reversed() }
        var results: [(Key, Any)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    // MARK: - del

    public mutating func del(_ key: Key) -> Any? {
        let oldValue = self[key]
        self[key] = nil
        return oldValue
    }

    public mutating func multiDel(_ keys: [Key]) -> [Key: Any] {
        var results: [Key: Any] = [:]
        keys.forEach { key in
            results[key] = self[key]
            self[key] = nil
        }
        return results
    }
}

extension Dictionary: Dictionariable where Key: Comparable {}

extension MMapKV: Dictionariable {
    public var keys: Dictionary<String, MMapable>.Keys {
        return dictionary.keys
    }
}

extension Dictionary: Redisable where Key: Comparable {}

extension MMapKV: Redisable {}
