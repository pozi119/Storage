
import Foundation

/// reference to  Enigma_FileType in common_data.proto
public enum FileType: Int, Storable {
    case unknown = 0, photo, image, sticker, audio, video, document, patch
}

public struct File: Storable {
    var id: String
    var url: String
    var path: String
    var type: FileType
    var extra_info: String
    var aeskey: String
    var name: String
    var suffix: String
    var md5: String
    var size: Int64
    var state: Int
    var transmission_size: Int64
    var ref_count: Int
    var create_time: Int64
    var last_motify_time: Int64
    var timestamp: Int64

    public init(id: String,
                url: String,
                path: String,
                type: FileType,
                extra_info: String,
                aeskey: String,
                name: String,
                suffix: String,
                md5: String,
                size: Int64,
                state: Int,
                transmission_size: Int64,
                ref_count: Int,
                create_time: Int64,
                last_motify_time: Int64,
                timestamp: Int64) {
        self.id = id
        self.url = url
        self.path = path
        self.type = type
        self.extra_info = extra_info
        self.aeskey = aeskey
        self.name = name
        self.suffix = suffix
        self.md5 = md5
        self.size = size
        self.state = state
        self.transmission_size = transmission_size
        self.ref_count = ref_count
        self.create_time = create_time
        self.last_motify_time = last_motify_time
        self.timestamp = timestamp
    }
}
