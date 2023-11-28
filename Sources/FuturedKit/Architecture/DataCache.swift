import Foundation

public actor DataCache<Model: Equatable> {
    @Published public private(set) var value: Model

    public init(value: Model) {
        self._value = Published(initialValue: value)
    }

    public func update(with value: Model) {
        guard value != self.value else { return }
        self.value = value
    }

    func update<each T: Equatable>(keyPath: repeat WritableKeyPath<Model, each T>, value: repeat each T) {
        var newValue = self.value
        repeat newValue[keyPath: each keyPath] = each value

        guard newValue != self.value else { return }
        self.value = newValue
    }
}
