import Foundation

public actor DataCache<Model: Equatable> {
    @inlinable
    @Published public private(set) var value: Model

    public init(value: Model) {
        self._value = Published(initialValue: value)
    }

    @inlinable
    public func update(with value: Model) {
        guard value != self.value else { return }
        self.value = value
    }

    @inlinable
    public func update<T: Equatable>(_ keyPath: WritableKeyPath<Model, T>, with value: T) {
        guard value != self.value[keyPath: keyPath] else { return }
        self.value[keyPath: keyPath] = value
    }

    @inlinable
    public func update<each T: Equatable>(keyPath: repeat WritableKeyPath<Model, each T>, value: repeat each T) {
        var newValue = self.value
        repeat newValue[keyPath: each keyPath] = each value
        self.value = newValue
    }
}
