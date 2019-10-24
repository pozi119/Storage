
import Foundation

public struct SecretKey: Storable {
    var user_id: Int64
    var device_id: Int64
    var version: Int
    var record: Data

    public init(user_id: Int64,
                device_id: Int64,
                version: Int,
                record: Data) {
        self.user_id = user_id
        self.device_id = device_id
        self.version = version
        self.record = record
    }
}

public struct DialogKey: Storable {
    var dialog_id: Int64
    var version: Int
    var record: Data

    public init(dialog_id: Int64,
                version: Int,
                record: Data) {
        self.dialog_id = dialog_id
        self.version = version
        self.record = record
    }
}
