//
//  Table.swift
//  Storage
//
//  Created by Valo on 2019/10/22.
//

import Foundation
import MMapKV
import Redisable
import SQLiteORM

public extension MMKVOrm {
    convenience init(_ name: String, db: Database, primaries: [String], uniques: [String] = []) {
        let dir = (db.path as NSString).deletingLastPathComponent
        let config = PlainConfig(T.self)
        config.primaries = primaries
        config.uniques = uniques
        let orm: Orm = Orm<T>(config: config, db: db, table: name)
        let mmkv: MMKV<String, T> = MMKV("com.enigma.mmkv." + name, directory: dir)
        self.init(store: orm, cache: mmkv)
    }
}

public struct Table {
    public var id: String
    public var db: DB

    private var messageOrms: [String: MMKVOrm<Message>] = [:]
    private var resourceOrms: [String: MMKVOrm<Resource>] = [:]

    public init(with id: String) {
        self.id = id
        db = DB(with: id)
    }

    // MARK: configDB

    static let account: MMKVOrm<Account> = {
        MMKVOrm("login_user_info_store", db: DB.configDB, primaries: ["id"])
    }()

    // MARK: coreDB

    public lazy var dialogKey: MMKVOrm<DialogKey> = {
        MMKVOrm("dialog_key_store", db: db.coreDB, primaries: ["dialog_id", "version"])
    }()

    public lazy var identityKey: MMKVOrm<SecretKey> = {
        MMKVOrm("identity_key_store", db: db.coreDB, primaries: ["user_id", "device_id", "version"])
    }()

    public lazy var preKey: MMKVOrm<SecretKey> = {
        MMKVOrm("pre_key_store", db: db.coreDB, primaries: ["user_id", "device_id", "version"])
    }()

    public lazy var signedPreKey: MMKVOrm<SecretKey> = {
        MMKVOrm("signed_pre_key_store", db: db.coreDB, primaries: ["user_id", "device_id", "version"])
    }()

    public lazy var sessionKey: MMKVOrm<SecretKey> = {
        MMKVOrm("session_key_store", db: db.coreDB, primaries: ["user_id", "device_id", "version"])
    }()

    // MARK: bufferDB

    public lazy var file: MMKVOrm<File> = {
        MMKVOrm("file", db: db.bufferDB, primaries: ["id"], uniques: ["md5"])
    }()

    // MARK: dataDB

    public lazy var dialog: MMKVOrm<Dialog> = {
        MMKVOrm("dialog_info_store", db: db.dataDB, primaries: ["id"])
    }()

    public lazy var friendRequest: MMKVOrm<FriendRequest> = {
        MMKVOrm("request_info_store", db: db.dataDB, primaries: ["user_id"])
    }()

    public lazy var user: MMKVOrm<User> = {
        MMKVOrm("user_info_store", db: db.dataDB, primaries: ["id"])
    }()

    public lazy var group: MMKVOrm<Group> = {
        MMKVOrm("group_info_store", db: db.dataDB, primaries: ["id"])
    }()

    public lazy var groupMember: MMKVOrm<GroupMember> = {
        MMKVOrm("group_member_info_store", db: db.dataDB, primaries: ["group_id", "user_id"])
    }()

    public lazy var stickerPacket: MMKVOrm<StickerPacket> = {
        MMKVOrm("stickers_info_store", db: db.dataDB, primaries: ["id"])
    }()

    // MARK: historyDB

    public lazy var unsentMessage: MMKVOrm<UnsentMessage> = {
        MMKVOrm("unsend_message_store", db: db.historyDB, primaries: ["dialog_id", "message_id"])
    }()

    public lazy var recentEmoji: MMKVOrm<RecentEmoji> = {
        MMKVOrm("recent_emoji_store", db: db.historyDB, primaries: ["unicode"])
    }()

    public lazy var recentSticker: MMKVOrm<RecentSticker> = {
        MMKVOrm("recent_sticker_store", db: db.historyDB, primaries: ["packet_id", "file_id"])
    }()

    mutating func messageOrm(_ dialogId: String) -> MMKVOrm<Message> {
        if let orm = messageOrms[dialogId] {
            return orm
        }
        let _orm = MMKVOrm<Message>(dialogId, db: db.historyDB, primaries: ["id"])
        messageOrms[dialogId] = _orm
        return _orm
    }

    mutating func resourceOrm(_ dialogId: String) -> MMKVOrm<Resource> {
        if let orm = resourceOrms[dialogId] {
            return orm
        }
        let _orm = MMKVOrm<Resource>("history_resource_store_" + dialogId,
                                     db: db.historyDB,
                                     primaries: ["message_id", "file_id"])
        resourceOrms[dialogId] = _orm
        return _orm
    }

    // MARK: searchDB

    public lazy var ftsMessage: Orm<Message> = {
        let config = FtsConfig(Message.self)
        config.whites = ["id", "dialog_id", "send_time", "text"]
        config.indexes = ["text"]
        config.tokenizer = "sqliteorm"
        return Orm<Message>(config: config, db: db.searchDB, table: "message_vtable")
    }()

    public lazy var ftsUser: Orm<User> = {
        let config = FtsConfig(User.self)
        config.whites = ["content", "timestamp"]
        config.indexes = ["phone", "name", "nick", "remark", "sign"]
        config.tokenizer = "sqliteorm"
        return Orm<User>(config: config, db: db.searchDB, table: "user_vtable")
    }()

    public lazy var ftsGroupMember: Orm<GroupMember> = {
        let config = FtsConfig(GroupMember.self)
        config.blacks = ["content", "timestamp"]
        config.indexes = ["username", "userNick", "groupNick"]
        config.tokenizer = "sqliteorm"
        return Orm<GroupMember>(config: config, db: db.searchDB, table: "member_vtable")
    }()
}
