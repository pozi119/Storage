//
//  DictionaryRedis.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation

public protocol Dictionariable {
    associatedtype Key: Hashable & Comparable
    associatedtype Value
    subscript(key: Key) -> Value? { get set }
    @inlinable var keys: Dictionary<Key, Value>.Keys { get }
}

extension Dictionariable {
    // MARK: - set

    public mutating func set(_ key: Key, value: Value) -> Int {
        self[key] = value
        return 1
    }

    public mutating func set<T: Equatable>(_ key: Key, value: T) -> Int {
        if let oldValue = self[key] as? T, oldValue == value {
            return 0
        }
        if let newValue = value as? Value {
            self[key] = newValue
            return 1
        }
        return -1
    }

    public mutating func multiSet(_ keyValues: [Key: Value]) -> [Key: Value] {
        keyValues.forEach { self[$0.key] = $0.value }
        return keyValues
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

    public func get(_ key: Key) -> Value? {
        return self[key]
    }

    public func multiGet(_ keys: [Key]) -> [Key: Value] {
        var results: [Key: Value] = [:]
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
                     order desc: Bool = false) -> [(Key, Value)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit, bounds: bounds, order: desc)
        var results: [(Key, Value)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    public func round(_ center: Key?, lower: Int, upper: Int, order desc: Bool = false) -> [(Key, Value)] {
        var _keys = keys(lower: center, limit: upper + 1, bounds: [.lower], order: false)
        if center != nil {
            _keys += keys(upper: center, limit: lower + 1, bounds: [], order: false)
        }
        _keys = desc ? _keys.sorted().reversed() : _keys.sorted()
        if desc { _keys = _keys.reversed() }
        var results: [(Key, Value)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    // MARK: - del

    public mutating func del(_ key: Key) -> Value? {
        let oldValue = self[key]
        self[key] = nil
        return oldValue
    }

    public mutating func multiDel(_ keys: [Key]) -> [Key: Value] {
        var results: [Key: Value] = [:]
        keys.forEach { key in
            results[key] = self[key]
            self[key] = nil
        }
        return results
    }
}
