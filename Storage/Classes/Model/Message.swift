
import Foundation

public extension Message {
    /// reference to  Enigma_Message.TypeEnum in common_data.proto
    enum `Type`: Int, Storable {
        case normal = 0, system, revoke, edit, call, deleted, revoked
    }

    enum State: Int, Storable {
        case unknown = 0, sending, sent, fail, read, revoked, deleted, error, edited
    }
}

public struct Message: Storable {
    public var id: Int64
    public var dialog_id: Int64
    public var type: Type
    public var state: State
    public var sender: Int32
    public var send_time: Int64
    public var text: String
    public var version: Int
    public var content: Data
}

public struct UnsentMessage: Storable {
    public var dialog_id: String
    public var message_id: Int64
    public var sub_id: Int64
    public var version: Int
    public var send_time: Int64
    public var content: Data
}

public struct Resource: Storable {
    public var message_id: Int64
    public var sender_id: Int64
    public var type: FileType
    public var keyword: String
    public var timestamp: Int64
    public var thum_id: String
    public var file_id: String
}
