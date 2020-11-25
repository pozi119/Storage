//
//  Dictionariable.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation

public protocol Dictionariable {
    associatedtype Key: Hashable & Comparable
    associatedtype Value: Equatable
    subscript(key: Key) -> Value? { get set }
    @inlinable var keys: Dictionary<Key, Value>.Keys { get }
}

extension Dictionariable {
    // MARK: - set

    public mutating func set(_ key: Key, value: Value) -> Int {
        if let oldValue = self[key], oldValue == value {
            return 0
        }
        self[key] = value
        return 1
    }

    public mutating func multiSet(_ keyValues: [Key: Value]) -> [Key: Value] {
        var results: [Key: Value] = [:]
        for (key, value) in keyValues {
            if let oldValue = self[key], oldValue == value {
                continue
            }
            self[key] = value
            results[key] = value
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
                     bounds: Bounds = .all,
                     desc: Bool = false) -> [Key] {
        let filtered = keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && (bounds.contains(.lower) ? key >= l : key > l) }
            if let u = upper { r = r && (bounds.contains(.upper) ? key <= u : key < u) }
            return r
        }
        let results = desc ? filtered.sorted().reversed() : filtered.sorted()
        if let l = limit, l < results.count {
            return [Key](results[0 ..< l])
        }
        return results
    }

    public func scan(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds = .all,
                     desc: Bool = false) -> [(Key, Value)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit, bounds: bounds, desc: desc)
        var results: [(Key, Value)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    public func round(_ center: Key?, lower: Int, upper: Int, desc: Bool = false) -> [(Key, Value)] {
        let after = scan(lower: center, limit: upper, bounds: [], desc: false)
        let front = center != nil ? scan(upper: center, limit: lower + 1, bounds: [.upper], desc: true).reversed() : []
        let array = front + after
        return desc ? array.reversed() : array
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

extension Dictionary: Dictionariable where Key: Comparable, Value: Equatable {}
extension Dictionary: Redisable where Key: Comparable, Value: Equatable {}
