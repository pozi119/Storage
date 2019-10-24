
import Foundation

public struct Group: Storable {
    var id: Int64
    var content: Data
    var timestamp: Int64

    public init(id: Int64,
                content: Data,
                timestamp: Int64) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

public struct GroupMember: Storable {
    var group_id: Int64
    var user_id: Int64
    var username: String
    var userNick: String
    var groupNick: String
    var content: Data
    var timestamp: Int64

    public init(group_id: Int64,
                user_id: Int64,
                username: String,
                userNick: String,
                groupNick: String,
                content: Data,
                timestamp: Int64) {
        self.group_id = group_id
        self.user_id = user_id
        self.username = username
        self.userNick = userNick
        self.groupNick = groupNick
        self.content = content
        self.timestamp = timestamp
    }
}
