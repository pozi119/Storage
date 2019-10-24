
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
    var id: Int64
    var dialog_id: Int64
    var type: Type
    var state: State
    var sender: Int32
    var send_time: Int64
    var text: String
    var version: Int
    var content: Data

    public init(id: Int64,
                dialog_id: Int64,
                type: Type,
                state: State,
                sender: Int32,
                send_time: Int64,
                text: String,
                version: Int,
                content: Data) {
        self.id = id
        self.dialog_id = dialog_id
        self.type = type
        self.state = state
        self.sender = sender
        self.send_time = send_time
        self.text = text
        self.version = version
        self.content = content
    }
}

public struct UnsentMessage: Storable {
    var dialog_id: String
    var message_id: Int64
    var sub_id: Int64
    var version: Int
    var send_time: Int64
    var content: Data

    public init(dialog_id: String,
                message_id: Int64,
                sub_id: Int64,
                version: Int,
                send_time: Int64,
                content: Data) {
        self.dialog_id = dialog_id
        self.message_id = message_id
        self.sub_id = sub_id
        self.version = version
        self.send_time = send_time
        self.content = content
    }
}

public struct Resource: Storable {
    var message_id: Int64
    var sender_id: Int64
    var type: FileType
    var keyword: String
    var timestamp: Int64
    var thum_id: String
    var file_id: String

    public init(message_id: Int64,
                sender_id: Int64,
                type: FileType,
                keyword: String,
                timestamp: Int64,
                thum_id: String,
                file_id: String) {
        self.message_id = message_id
        self.sender_id = sender_id
        self.type = type
        self.keyword = keyword
        self.timestamp = timestamp
        self.thum_id = thum_id
        self.file_id = file_id
    }
}
