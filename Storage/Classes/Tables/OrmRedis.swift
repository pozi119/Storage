//
//  OrmKeyValue.swift
//  Storage
//
//  Created by Valo on 2019/10/12.
//

import Foundation
import Redisable
import SQLiteORM

private let separator = "||"

extension Orm: Redisable where T: Equatable {
    public typealias Key = String
    public typealias Value = T

    public func primaryKeyValue(of key: String) -> [String: Binding]? {
        guard let conf = config as? PlainConfig else { return nil }
        guard conf.primaries.count > 0 else { return nil }
        let values = key.components(separatedBy: separator)
        guard values.count == conf.primaries.count else { return nil }
        var result: [String: Binding] = [:]
        for i in 0 ..< values.count {
            let k = conf.primaries[i]
            let v = values[i]
            result[k] = v
        }
        return result
    }

    public func keyValue(of value: T) -> (String, [String: Binding]) {
        let result: (String, [String: Binding]) = ("", [:])
        guard let conf = config as? PlainConfig,
            conf.primaries.count > 0,
            let _val = try? encoder.encode(value) as? [String: Binding] else { return result }
        let array = conf.primaries.map { String(describing: _val[$0] ?? "") }
        let _key = array.joined(separator: separator)
        return (_key, _val)
    }

    private func constraint(lower: String?, upper: String?, bounds: Bounds, primaries: [String]) -> Where? {
        let count = primaries.count
        var lvalues = (lower ?? "").components(separatedBy: separator)
        var uvalues = (upper ?? "").components(separatedBy: separator)
        lvalues = lvalues + Array(repeating: "", count: Swift.max(0, count - lvalues.count))
        uvalues = uvalues + Array(repeating: "", count: Swift.max(0, count - uvalues.count))
        var condition = Where("")
        for i in 0 ..< count {
            let pk = primaries[i], l = lvalues[i], u = uvalues[i]
            condition = condition && (bounds.contains(.lower) ? (Where(pk) >= l) : (Where(pk) > l))
            if u.count == 0 { continue }
            condition = condition && (bounds.contains(.upper) ? (Where(pk) <= u) : (Where(pk) < u))
        }
        return condition
    }

    public func set(_ key: String, value: T) -> Int {
        if let oldValue = get(key), oldValue == value {
            return 0
        }

        let (_key, _val) = keyValue(of: value)
        guard key == _key else { return -1 }
        let r = upsert(keyValues: _val)
        return r ? 1 : 0
    }

    public func multiSet(_ keyValues: [String: Value]) -> [String: Value] {
        var multi: [[String: Binding]] = []
        var result: [String: Value] = [:]
        for (key, value) in keyValues {
            let (_key, _val) = keyValue(of: value)
            if key == _key {
                multi.append(_val)
                result[key] = value
            }
        }
        let r = upsert(multiKeyValues: multi)
        return r == multi.count ? result : [:]
    }

    public func get(_ key: String) -> Value? {
        guard let dic = primaryKeyValue(of: key),
            let condition = constraint(for: dic) else { return nil }
        return xFindOne(condition)
    }

    public func multiGet(_ keys: [String]) -> [String: Value] {
        var results: [String: Value] = [:]
        for key in keys {
            if let dic = primaryKeyValue(of: key),
                let condition = constraint(for: dic) {
                results[key] = xFindOne(condition)
            }
        }
        return results
    }

    public func exists(_ key: String) -> Bool {
        guard let dic = primaryKeyValue(of: key) else { return false }
        return exist(dic)
    }

    public func keys(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds,
                     order desc: Bool = false) -> [String] {
        guard let conf = config as? PlainConfig,
            conf.primaries.count > 0,
            let condition = constraint(lower: lower, upper: upper, bounds: bounds, primaries: conf.primaries)
        else { return [] }
        let orderBy = OrderBy(desc ? conf.primaries.map { $0 + " DESC" } : conf.primaries)
        let items = xFind(condition, fields: Fields(conf.primaries), orderBy: orderBy, limit: Int64(limit ?? 0))
        return items.map { keyValue(of: $0).0 }
    }

    public func scan(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds,
                     order desc: Bool = false) -> [(String, Value)] {
        guard let conf = config as? PlainConfig,
            conf.primaries.count > 0,
            let condition = constraint(lower: lower, upper: upper, bounds: bounds, primaries: conf.primaries)
        else { return [] }
        let orderBy = OrderBy(desc ? conf.primaries.map { $0 + " DESC" } : conf.primaries)
        let items = xFind(condition, orderBy: orderBy, limit: Int64(limit ?? 0))
        return items.map { (keyValue(of: $0).0, $0) }
    }

    public func round(_ center: String?, lower: Int, upper: Int, order desc: Bool) -> [(String, Value)] {
        let after = scan(lower: center, limit: upper, bounds: [.lower], order: desc)
        let front: [(String, Value)] = center == nil ? [] : scan(upper: center, limit: lower, bounds: [], order: desc)
        return desc ? after + front : front + after
    }

    public func del(_ key: String) -> Value? {
        guard let dic = primaryKeyValue(of: key),
            let condition = constraint(for: dic) else { return nil }
        let result = xFindOne(condition)
        delete(where: condition)
        return result
    }

    public func multiDel(_ keys: [String]) -> [String: Value] {
        var results: [String: Value] = [:]
        for key in keys {
            if let dic = primaryKeyValue(of: key),
                let condition = constraint(for: dic) {
                results[key] = xFindOne(condition)
                delete(where: condition)
            }
        }
        return results
    }
}
