//
//  OrmRedisable.swift
//  Storage
//
//  Created by Valo on 2019/10/12.
//

import AnyCoder
import Foundation
import SQLiteORM

private let separator = "||"

private struct AssociatedKey {
    static var redisableKey: String = "redisableKey"
}

extension Orm: Redisable where T: Equatable {
    public typealias Key = String
    public typealias Value = T

    var redisableKey: String {
        if let key = objc_getAssociatedObject(self, &AssociatedKey.redisableKey) as? String {
            return key
        }

        let key = config.primaries.count == 1 ? config.primaries.first! : ""
        if key.count == 0 {
            assert(false, "invalid redisable orm")
        }
        objc_setAssociatedObject(self, &AssociatedKey.redisableKey, key, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        return key
    }

    public func keyValue(of value: Value) -> (String, [String: Primitive]) {
        let result: (String, [String: Primitive]) = ("", [:])
        guard let val = try? AnyEncoder.encode(value),
              let _key = val[redisableKey] else { return result }
        let key = String(describing: _key)
        return (key, val)
    }

    private func constraint(lower: String?, upper: String?, bounds: Bounds) -> Where {
        var condition = Where("")
        let pk = redisableKey
        if let l = lower {
            condition = condition && (bounds.contains(.lower) ? (Where(pk) >= l) : (Where(pk) > l))
        }
        if let u = upper {
            condition = condition && (bounds.contains(.upper) ? (Where(pk) <= u) : (Where(pk) < u))
        }
        return condition
    }

    public func set(_ key: String, value: Value) -> Int {
        if let oldValue = get(key), oldValue == value {
            return 0
        }

        let (_key, _val) = keyValue(of: value)
        guard key == _key else { return -1 }
        let r = upsert(keyValues: _val)
        return r ? 1 : 0
    }

    public func multiSet(_ keyValues: [String: Value]) -> [String: Value] {
        var multi: [[String: Primitive]] = []
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
        return xFindOne([redisableKey: key])
    }

    public func multiGet(_ keys: [String]) -> [String: Value] {
        var results: [String: Value] = [:]
        for key in keys {
            results[key] = xFindOne([redisableKey: key])
        }
        return results
    }

    public func exists(_ key: String) -> Bool {
        return exist([redisableKey: key])
    }

    public func keys(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds = .all,
                     desc: Bool = false) -> [String] {
        let condition = constraint(lower: lower, upper: upper, bounds: bounds)
        let orderBy = OrderBy(desc ? redisableKey + " DESC" : redisableKey)
        let items = find(condition, fields: Fields(redisableKey), orderBy: orderBy, limit: Int64(limit ?? 0))
        return items.map { String(describing: $0.values.first ?? "") }
    }

    public func scan(lower: Key? = nil,
                     upper: Key? = nil,
                     limit: Int? = nil,
                     bounds: Bounds = .all,
                     desc: Bool = false) -> [(String, Value)] {
        let condition = constraint(lower: lower, upper: upper, bounds: bounds)
        let orderBy = OrderBy(desc ? redisableKey + " DESC" : redisableKey)
        let items = find(condition, orderBy: orderBy, limit: Int64(limit ?? 0))
        var results: [(String, Value)] = []
        for dic in items {
            let k = String(describing: dic[redisableKey] ?? "")
            if let v = try? AnyDecoder.decode(T.self, from: dic) {
                results.append((k, v))
            }
        }
        return results
    }

    public func round(_ center: String?, lower: Int, upper: Int, desc: Bool) -> [(String, Value)] {
        let after = scan(lower: center, limit: upper, bounds: [], desc: false)
        let front = center != nil ? scan(upper: center, limit: lower + 1, bounds: [.upper], desc: true).reversed() : []
        let array = front + after
        return desc ? array.reversed() : array
    }

    public func del(_ key: String) -> Value? {
        let condition: Where = [redisableKey: key]
        let result = xFindOne(condition)
        delete(where: condition)
        return result
    }

    public func multiDel(_ keys: [String]) -> [String: Value] {
        var results: [String: Value] = [:]
        for key in keys {
            let condition: Where = [redisableKey: key]
            results[key] = xFindOne(condition)
            delete(where: condition)
        }
        return results
    }
}
