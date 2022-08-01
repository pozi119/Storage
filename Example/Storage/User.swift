
import Foundation
import Storage_Redisable

public struct User: Equatable {
    var id: Int64
    var name: String
    var photo: String
    var remark: String
}
