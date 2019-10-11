//
//  MMapKVCache.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation
import MMapKV

extension MMapKV: Cacheable {
    public typealias T = MMapable

    public typealias Key = String

    // MARK: - set

    public func set<T>(_ key: String, value: T) -> Int where T: Equatable {
        guard let oldValue = self[key] as? T else { return -1 }
        if oldValue == value { return 0 }
        guard let newValue = value as? MMapable else { return 0 }
        self[key] = newValue
        return 1
    }

    public func multiSet<T>(_ keyValues: [String: T]) -> [String: T] where T: Equatable {
        var results: [String: T] = [:]
        for (key, value) in keyValues {
            if let oldValue = self[key] as? T, oldValue == value {
                continue
            }
            if let newValue = value as? MMapable {
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
        var results: [String: MMapable] = [:]
        keys.forEach { results[$0] = self[$0] }
        return results
    }

    public func exists(_ key: Key) -> Bool {
        return dictionary.keys.contains(key)
    }

    public func keys(lower: Key? = nil, upper: Key? = nil, limit: Int? = nil) -> [Key] {
        let keys = dictionary.keys.sorted()
        let filtered = keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && key > l }
            if let u = upper { r = r && key <= u }
            return r
        }
        if let l = limit, l < filtered.count {
            return [String](filtered[0 ..< l])
        }
        return filtered
    }

    public func rkeys(lower: Key? = nil, upper: Key? = nil, limit: Int? = nil) -> [Key] {
        let keys = dictionary.keys.sorted().reversed()
        let filtered = keys.filter { (key) -> Bool in
            var r = true
            if let l = lower { r = r && key >= l }
            if let u = upper { r = r && key < u }
            return r
        }
        if let l = limit, l < filtered.count {
            return [String](filtered[0 ..< l])
        }
        return filtered
    }

    public func scan(lower: Key? = nil, upper: Key? = nil, limit: Int? = nil) -> [(Key, Any)] {
        let _keys = keys(lower: lower, upper: upper, limit: limit)
        var results: [(String, MMapable)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    public func rscan(lower: Key? = nil, upper: Key? = nil, limit: Int? = nil) -> [(Key, Any)] {
        let _keys = rkeys(lower: lower, upper: upper, limit: limit)
        var results: [(String, MMapable)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    public func round(_ center: Key, lower: Int, upper: Int, order desc: Bool = false) -> [(Key, Any)] {
        let lkeys = rkeys(upper: center, limit: lower)
        let ukeys = keys(lower: center, limit: upper)
        var _keys = (lkeys + ukeys).sorted()
        if desc { _keys = _keys.reversed() }
        var results: [(String, MMapable)] = []
        _keys.forEach { results.append(($0, self[$0]!)) }
        return results
    }

    // MARK: - del

    public func del(_ key: Key) -> Any? {
        let oldValue = self[key]
        self[key] = nil
        return oldValue
    }

    public func multiDel(_ keys: [Key]) -> [String: Any] {
        var results: [String: MMapable] = [:]
        keys.forEach { key in
            results[key] = self[key]
            self[key] = nil
        }
        return results
    }
}
