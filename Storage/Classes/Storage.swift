
import Foundation
import SwiftSignalKitMac

protocol Storable: Codable, Equatable {}

//public protocol Table {
//    func begin()
//    func commit()
//    func rollback()
//
//    func transaction<T>(_ block: () -> Void) -> Signal<T, Error>
//}
