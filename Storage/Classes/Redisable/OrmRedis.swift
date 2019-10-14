//
//  OrmKeyValue.swift
//  Storage
//
//  Created by Valo on 2019/10/12.
//

import Foundation
import SQLiteORM

private let separator = "||"

extension Orm: Redisable {
    public typealias Key = String
    public typealias Value = [String: Binding]

    private func primaryKeyValue(of key: String, primaries: [String]) -> Value? {
        guard primaries.count > 0 else { return nil }
        let values = key.components(separatedBy: separator)
        guard values.count == primaries.count else { return nil }
        var result: Value = [:]
        for i in 0 ..< values.count {
            let k = primaries[i]
            let v = values[i]
            result[k] = v
        }
        return result
    }

    private func keyString(of primaryKeyValue: Value, primaries: [String]) -> String {
        guard primaries.count > 0 else { return "" }
        let values = primaries.map { String(describing: primaryKeyValue[$0] ?? "") }
        return values.joined(separator: separator)
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

    public func set<T>(_ key: String, value: T) -> Int where T: Equatable {
        guard let newValue = value as? Value, let conf = config as? PlainConfig else { return -1 }
        let str = keyString(of: newValue, primaries: conf.primaries)
        guard key == str else { return -1 }
        let r = upsert(keyValues: newValue)
        return r ? 1 : 0
    }

    public func multiSet<T>(_ keyValues: [String: T]) -> [String: T] where T: Equatable {
        guard let conf = config as? PlainConfig else { return [:] }
        var multi: [[String: Binding]] = []
        var result: [String: T] = [:]
        for (key, value) in keyValues {
            if let newValue = value as? Value {
                let str = keyString(of: newValue, primaries: conf.primaries)
                if key == str {
                    multi.append(newValue)
                    result[key] = value
                }
            }
        }
        let r = upsert(multiKeyValues: multi)
        return r == multi.count ? result : [:]
    }

    public func get(_ key: String) -> Any? {
        guard let conf = config as? PlainConfig,
            let dic = primaryKeyValue(of: key, primaries: conf.primaries),
            let condition = constraint(for: dic) else { return nil }
        return findOne(condition)
    }

    public func multiGet(_ keys: [String]) -> [String: Any] {
        guard let conf = config as? PlainConfig else { return [:] }
        var results: [String: Any] = [:]
        for key in keys {
            if let dic = primaryKeyValue(of: key, primaries: conf.primaries),
                let condition = constraint(for: dic) {
                results[key] = findOne(condition)
            }
        }
        return results
    }

    public func exists(_ key: String) -> Bool {
        guard let conf = config as? PlainConfig,
            let dic = primaryKeyValue(of: key, primaries: conf.primaries) else { return false }
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
        let keyValues = find(condition, fields: Fields(conf.primaries), orderBy: orderBy, limit: Int64(limit ?? 0))
        return keyValues.map { keyString(of: $0, primaries: conf.primaries) }
    }

    public func scan(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds,
                     order desc: Bool = false) -> [(String, Any)] {
        guard let conf = config as? PlainConfig,
            conf.primaries.count > 0,
            let condition = constraint(lower: lower, upper: upper, bounds: bounds, primaries: conf.primaries)
        else { return [] }
        let orderBy = OrderBy(desc ? conf.primaries.map { $0 + " DESC" } : conf.primaries)
        let keyValues = find(condition, orderBy: orderBy, limit: Int64(limit ?? 0))
        return keyValues.map { (keyString(of: $0, primaries: conf.primaries), $0) }
    }

    public func round(_ center: String?, lower: Int, upper: Int, order desc: Bool) -> [(String, Any)] {
        let after = scan(lower: center, limit: upper, bounds: [.lower], order: desc)
        let front: [(String, Any)] = center == nil ? [] : scan(upper: center, limit: lower, bounds: [], order: desc)
        return desc ? after + front : front + after
    }

    public func del(_ key: String) -> Any? {
        guard let conf = config as? PlainConfig,
            let dic = primaryKeyValue(of: key, primaries: conf.primaries),
            let condition = constraint(for: dic) else { return nil }
        let result = findOne(condition)
        delete(where: condition)
        return result
    }

    public func multiDel(_ keys: [String]) -> [String: Any] {
        guard let conf = config as? PlainConfig else { return [:] }
        var results: [String: Any] = [:]
        for key in keys {
            if let dic = primaryKeyValue(of: key, primaries: conf.primaries),
                let condition = constraint(for: dic) {
                results[key] = findOne(condition)
                delete(where: condition)
            }
        }
        return results
    }
}
