//
//  KeyValueable.swift
//  Storage
//
//  Created by Valo on 2019/10/12.
//

import Foundation

public struct Bounds: OptionSet {
    public let rawValue: UInt

    public static let lower = Bounds(rawValue: 1)
    public static let upper = Bounds(rawValue: 2)

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
}

public protocol Redisable {
    associatedtype Key: Hashable & Comparable
    associatedtype Value

    // MARK: - set

    /// Set the value of the key.
    /// - Returns: -1 failure;  0 success ; 1 success and update
    mutating func set(_ key: Key, value: Value) -> Int
    mutating func set<T: Equatable>(_ key: Key, value: T) -> Int

    /// Set the values related to the specified multiple keys
    /// - Returns: updated key-value pairs
    mutating func multiSet(_ keyValues: [Key: Value]) -> [Key: Value]
    mutating func multiSet<T: Equatable>(_ keyValues: [Key: T]) -> [Key: T]

    // MARK: - get

    /// Get the value related to the specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    mutating func get(_ key: Key) -> Value?

    /// Get the values related to the specified multiple keys
    /// - Returns:  key-value pairs
    mutating func multiGet(_ keys: [Key]) -> [Key: Value]

    /// Verify if the specified key exists.
    mutating func exists(_ key: Key) -> Bool

    /// List keys in range (lower, upper], asc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many keys will be returned
    /// - Parameter desc: Results in reverse order or not
    mutating func keys(lower: Key?, upper: Key?, limit: Int?, bounds: Bounds, order desc: Bool) -> [Key]

    /// List key-value pairs with keys in range (lower, upper]
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    /// - Parameter desc: Results in reverse order or not
    mutating func scan(lower: Key?, upper: Key?, limit: Int?, bounds: Bounds, order desc: Bool) -> [(Key, Value)]

    /// List key-value pairs with keys in range (center - lower, center + upper)
    /// - Parameter upper: The upper bound(not included) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter lower: The lower bound(inclusive) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    /// - Parameter desc: Results in reverse order or not
    mutating func round(_ center: Key?, lower: Int, upper: Int, order desc: Bool) -> [(Key, Value)]

    // MARK: - del

    /// Delete specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    mutating func del(_ key: Key) -> Value?

    /// Delete specified multiple keys.
    /// - Returns: deleted key-value pairs
    mutating func multiDel(_ keys: [Key]) -> [Key: Value]
}
