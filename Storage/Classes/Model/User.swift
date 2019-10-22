
import Foundation

public struct FriendRequest: Storable {
    /// reference to  Enigma_ContactRequestState in common_data.proto
    public enum State: Int, Storable {
        case pending = 0, read, accepted, refused, expired, deleted
    }

    public var user_id: Int64
    public var state: State
    public var content: Data
    public var timestamp: Int64
}

public struct User: Storable {
    public var id: Int64
    public var phone: String
    public var name: String
    public var nick: String
    public var remark: String
    public var sign: String
    public var content: Data
    public var timestamp: Int64
}
