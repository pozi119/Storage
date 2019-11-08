
import Foundation

public extension FriendRequest {
    /// reference to  Enigma_ContactRequestState in common_data.proto
    enum State: Int, Storable {
        case pending = 0, read, accepted, refused, expired, deleted
    }
}

public struct FriendRequest: Storable {
    var user_id: Int64
    var state: State
    var content: Data
    var timestamp: TimeInterval

    public init(user_id: Int64,
                state: State,
                content: Data,
                timestamp: TimeInterval) {
        self.user_id = user_id
        self.state = state
        self.content = content
        self.timestamp = timestamp
    }
}

public struct User: Storable {
    var id: Int64
    var phone: String
    var name: String
    var nick: String
    var remark: String
    var sign: String
    var content: Data
    var timestamp: TimeInterval

    public init(id: Int64,
                phone: String,
                name: String,
                nick: String,
                remark: String,
                sign: String,
                content: Data,
                timestamp: TimeInterval) {
        self.id = id
        self.phone = phone
        self.name = name
        self.nick = nick
        self.remark = remark
        self.sign = sign
        self.content = content
        self.timestamp = timestamp
    }
}
