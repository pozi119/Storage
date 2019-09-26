
import Foundation

public struct Group: Storable {
    public var id: Int64
    public var content: Data
    public var timestamp: Int64
}

public struct GroupMember: Storable {
    public var group_id: Int64
    public var user_id: Int64
    public var content: Data
    public var timestamp: Int64
}
