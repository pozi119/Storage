
import Foundation
import Storage

public struct User: Storable {
    var id: Int64
    var name: String
    var photo: String
    var remark: String
}
