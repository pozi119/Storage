
import Foundation

public struct Account: Storable {
    public var id: Int64
    public var name: String
    public var photo: String
    public var last_login_time: Int64
    public var remark: String
}
