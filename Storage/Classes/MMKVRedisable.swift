//
//  MMKVRedisable.swift
//  Storage
//
//  Created by Valo on 2019/10/16.
//

import Foundation
import MMapKV

extension MMKV: Dictionariable where Key: Comparable, Value: Equatable {
    public var keys: Dictionary<Key, Value>.Keys {
        return dictionary.keys
    }
}

extension MMKV: Redisable where Key: Comparable, Value: Equatable {}
