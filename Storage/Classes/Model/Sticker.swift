
import Foundation

public struct StickerPacket: Storable {
    var id: Int64
    var content: Data
    var timestamp: Int64

    public init(id: Int64,
                content: Data,
                timestamp: Int64) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

public struct RecentEmoji: Storable {
    var unicode: String
    var timestamp: Int64

    public init(unicode: String,
                timestamp: Int64) {
        self.unicode = unicode
        self.timestamp = timestamp
    }
}

public struct RecentSticker: Storable {
    var packet_id: Int64
    var file_id: String
    var timestamp: Int64

    public init(packet_id: Int64,
                file_id: String,
                timestamp: Int64) {
        self.packet_id = packet_id
        self.file_id = file_id
        self.timestamp = timestamp
    }
}
