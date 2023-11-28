import Foundation

protocol ComponentModel: ObservableObject {
    associatedtype Event

    var onEvent: (Event) -> Void { get }
}
