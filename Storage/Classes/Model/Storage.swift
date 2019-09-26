
import Foundation
import SwiftSignalKitMac

/// reference to  Enigma_FileType in common_data.proto
public enum FileType: Int, Storable {
    case unknown = 0, photo, image, sticker, audio, video, document, patch
}

protocol Storable: Codable, Equatable {}

public protocol Table {
    func begin()
    func commit()
    func rollback()

    func transaction<T>(_ block: () -> Void) -> Signal<T, Error>
}
