//  ___FILEHEADER___

protocol Mockable {
    nonisolated static var mock: Self { get }
}

extension Mockable where Self: Equatable {
    nonisolated var isMock: Bool {
        self == Self.mock
    }
}
