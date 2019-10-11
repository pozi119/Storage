//
//  Cacheable.swift
//  Storage
//
//  Created by Valo on 2019/10/11.
//

import Foundation

public protocol Cacheable {
    associatedtype Key: Hashable & Comparable

    // MARK: - set

    /// Set the value of the key.
    /// - Returns: -1 failure;  0 success ; 1 success and update
    func set<T>(_ key: String, value: T) -> Int where T: Equatable

    /// multi set
    /// - Parameter keyValues: key-value pairs
    /// - Returns: updated key-value pairs
    func multiSet<T>(_ keyValues: [String: T]) -> [String: T] where T: Equatable

    // MARK: - get

    /// Get the value related to the specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    func get(_ key: Key) -> Any?

    /// Get the values related to the specified multiple keys
    /// - Returns:  key-value pairs
    func multiGet(_ keys: [Key]) -> [Key: Any]

    /// Verify if the specified key exists.
    func exists(_ key: Key) -> Bool

    /// List keys in range (lower, upper], asc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many keys will be returned
    func keys(lower: Key?, upper: Key?, limit: Int?) -> [Key]

    /// List keys in range [lower, upper), desc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many keys will be returned
    func rkeys(lower: Key?, upper: Key?, limit: Int?) -> [Key]

    /// List key-value pairs with keys in range (lower, upper], asc
    /// - Parameter lower: The lower bound(not included) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter upper: The upper bound(inclusive) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    func scan(lower: Key?, upper: Key?, limit: Int?) -> [(Key, Any)]

    /// List key-value pairs with keys in range [lower, upper), desc
    /// - Parameter upper: The upper bound(not included) of keys to be returned, empty string means +inf(no limit).
    /// - Parameter lower: The lower bound(inclusive) of keys to be returned, empty string means -inf(no limit).
    /// - Parameter limit: Up to that many pairs will be returned
    func rscan(lower: Key?, upper: Key?, limit: Int?) -> [(Key, Any)]

    func round(_ center: Key, lower: Int, upper: Int, order desc: Bool) -> [(Key, Any)]

    // MARK: - del

    /// Delete specified key.
    /// - Returns: Return the value to the key, if the key does not exists, return nil
    func del(_ key: Key) -> Any?

    /// Delete specified multiple keys.
    /// - Returns: deleted key-value pairs
    func multiDel(_ keys: [Key]) -> [Key: Any]
}
