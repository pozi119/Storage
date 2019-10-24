
import Foundation

public struct Account: Storable {
    var id: Int64
    var name: String
    var photo: String
    var last_login_time: Int64
    var remark: String

    public init(id: Int64,
                name: String,
                photo: String,
                last_login_time: Int64,
                remark: String) {
        self.id = id
        self.name = name
        self.photo = photo
        self.last_login_time = last_login_time
        self.remark = remark
    }
}
