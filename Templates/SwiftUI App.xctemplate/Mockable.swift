//  ___FILEHEADER___

protocol Mockable {
    static var mock: Self { get }
}

extension Mockable where Self: Equatable {
    var isMock: Bool {
        self == Self.mock
    }
}
