
import Foundation

public struct File: Storable {
    public var id: String
    public var url: String
    public var path: String
    public var type: FileType
    public var extra_info: String
    public var aeskey: String
    public var name: String
    public var suffix: String
    public var md5: String
    public var size: Int64
    public var state: Int
    public var transmission_size: Int64
    public var ref_count: Int
    public var create_time: Int64
    public var last_motify_time: Int64
    public var timestamp: Int64
}
