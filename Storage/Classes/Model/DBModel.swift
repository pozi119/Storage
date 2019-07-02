//
//  Message.swift
//  Storage
//
//  Created by Valo on 2019/6/25.
//

import Foundation

public struct DBModel {
    // MARK: - general configuration

    /// general configuration
    public struct Config: Codable {
        var item: String
        var value: String
        var remark: String = ""
    }

    // MARK: -  configuration database

    /// login user info
    struct Account: Codable {
        var id: UInt64
        var password: String
        var name: String
        var photo: String
        var last_login: TimeInterval
        var remark: String = ""
    }

    // MARK: - core database

    /// dialog key
    struct DialogKey: Codable {
        var id: String
        var version: Int
        var record: Data
    }

    /// secret key
    struct SecretKey: Codable {
        var user_id: Int
        var device_id: Int
        var version: Int
        var record: Data
    }

    // MARK: - cache database

    /// cache file
    struct File: Codable {
        var id: String
        var url: String
        var path: String
        var type: Int
        var extra_info: String
        var aes_key: String
        var name: String
        var suffix: String
        var md5: String
        var size: Int
        var state: Int
        var transmission_size: Int
        var ref_count: Int
        var create_at: TimeInterval
        var update_at: TimeInterval
        var timestamp: TimeInterval
    }

    // MARK: - sync infomation

    /// dialog info
    struct Dialog: Codable {
        var id: String
        var is_pin: Bool = false
        var content: Data
        var timestamp: TimeInterval
    }

    /// request friend infomation
    struct Request: Codable {
        var id: Int
        var content: Data
        var timestamp: TimeInterval
    }

    /// user infomation
    struct User: Codable {
        var id: Int
        var content: Data
        var timestamp: TimeInterval
    }

    /// group infomation
    struct Group: Codable {
        var id: Int
        var content: Data
        var timestamp: TimeInterval
    }

    /// sticker infomation
    struct Sticker: Codable {
        var id: Int
        var content: Data
        var timestamp: TimeInterval
    }

    /// group member infomation
    struct GroupMember: Codable {
        var group_id: Int
        var user_id: Int
        var content: Data
        var timestamp: TimeInterval
    }

    // MARK: - history mapping

    /// emoji
    struct Emoji: Codable {
        var unicode: Int
        var timestamp: TimeInterval
    }

    /// sticker
    struct HistorySticker: Codable {
        var packet_id: Int
        var file_id: String
        var timestamp: TimeInterval
    }

    /// unsend message
    struct UnsendMessage: Codable {
        var dialog_id: String
        var message_id: UInt64
        var sub_id: Int
        var version: Int
        var send_time: TimeInterval
        var content: Data
    }

    /// resource statsitic
    struct ResourceStats: Codable {
        var dialog_id: String
        var type: Int
        var time: TimeInterval
        var item_count: Int
    }

    /// resource storage
    struct Resource: Codable {
        var message_id: UInt64
        var sender_id: UInt64
        var type: Int
        var keyword: String
        var timestamp: TimeInterval
        var thumb_id: String
        var file_id: String
    }

    // MARK: - history message

    /// history message
    public struct Message: Codable {
        var id: UInt64
        var type: Int
        var state: Int
        var sender_id: UInt64
        var send_time: TimeInterval
        var source_data: Data
        var version: Int
        var content: Data
    }

    // MARK: - full text search

    /// fts message
    public struct FtsMessage: Codable {
        var message_id: UInt64
        var sender_id: UInt64
        var send_time: TimeInterval
        var info: String
    }
}
