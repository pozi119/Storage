
import Foundation

public struct File: Storable {
    var id: String
    var md5: String = ""
    var path: String = ""
    var mime: String = ""
    var ext: String = ""
    var createAt: TimeInterval = 0
    var updateAt: TimeInterval = 0

    public init(id: String,
                md5: String = "",
                path: String = "",
                mime: String = "",
                ext: String = "",
                createAt: TimeInterval = 0,
                updateAt: TimeInterval = 0) {
        self.id = id
        self.md5 = md5
        self.path = path
        self.mime = mime
        self.ext = ext
        self.createAt = createAt
        self.updateAt = updateAt
    }
}
