
import Foundation

public struct Account: Storable {
    var id: Int64
    var name: String
    var photo: String
    var remark: String
    var last_login_time: TimeInterval

    public init(id: Int64,
                name: String,
                photo: String,
                remark: String,
                last_login_time: TimeInterval) {
        self.id = id
        self.name = name
        self.photo = photo
        self.remark = remark
        self.last_login_time = last_login_time
    }
}
