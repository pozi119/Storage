
import Foundation

public struct Dialog: Storable {
    public var id: String
    public var is_pin: Bool
    public var content: Data
    public var timestamp: Int64
}
