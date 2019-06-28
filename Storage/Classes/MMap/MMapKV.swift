//
//  MMapTable.swift
//  Storage
//
//  Created by Valo on 2019/6/26.
//

import Foundation

public class MMapKV {
    private var dictionary: [String: MMapable] = [:]
    private var mmapfile: MMapFile
    private var dataSize: Int = 0

    public init(_ id: String = "com.enigma.mmapkv") {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dir = (documentDirectory as NSString).appendingPathComponent("MMapKV")
        let fm = FileManager.default
        var isdir: ObjCBool = false
        let exist = fm.fileExists(atPath: dir, isDirectory: &isdir)
        if !exist || !isdir.boolValue {
            try? fm.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        }
        let path = (dir as NSString).appendingPathComponent(id)
        mmapfile = MMapFile(path: path)
        let bytes = Data(bytes: mmapfile.memory, count: mmapfile.size).bytes
        let meta = MMapItem.enumerate(bytes)
        dictionary = meta.kv
        dataSize = meta.size
    }

    public subscript(key: String) -> MMapable? {
        get {
            return dictionary[key]
        }
        set(newValue) {
            dictionary[key] = newValue
            let mmaped = MMapItem(key: key, value: newValue)
            append(mmaped.storage)
        }
    }

    private func append(_ bytes: [UInt8]) {
        let len = bytes.count
        let end = dataSize + len
        if end > mmapfile.size {
            mmapfile.size = end
            resize()
        }
        let range: Range<Int> = Range(uncheckedBounds: (dataSize, end))
        mmapfile.write(at: range, from: bytes)
        dataSize = end
    }

    public func resize() {
        mmapfile.clear()
        dataSize = 0
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}
