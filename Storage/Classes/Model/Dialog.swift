
import Foundation

public struct Dialog: Storable {
    var id: String
    var is_pin: Bool
    var content: Data
    var timestamp: Int64

    public init(id: String,
                is_pin: Bool,
                content: Data,
                timestamp: Int64) {
        self.id = id
        self.is_pin = is_pin
        self.content = content
        self.timestamp = timestamp
    }
}
