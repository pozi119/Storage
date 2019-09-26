
import Foundation

public struct SecretKey: Storable {
    public var user_id: Int64
    public var device_id: Int64
    public var version: Int
    public var record: Data
}

public struct DialogKey: Storable {
    public var dialog_id: Int64
    public var version: Int
    public var record: Data
}
