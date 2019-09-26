
import Foundation

public struct StickerPacket: Storable {
    public var id: Int64
    public var content: Data
    public var timestamp: Int64
}

public struct RecentEmoji: Storable {
    public var unicode: String
    public var timestamp: Int64
}

public struct RecentSticker: Storable {
    public var packet_id: Int64
    public var file_id: String
    public var timestamp: Int64
}
