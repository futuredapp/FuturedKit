import Foundation

/// `DataCache` is intended to store application state which may be used by
/// more than one *component* and/or fetched from remote.
///
/// An Application should contain one shared application-wide cache, but each
/// coordinator may also create a private data cache.
///
/// The data from data cache should be taken as a subscription and modified
/// only via provided `update` methods. As a general rule, value types should
/// be used as a `Model`.
///
/// - Experiment: This API is in preview and subjet to change.
/// - ToDo: How the `DataCache` may interact with persistance such as
/// `CoreData` or `SwiftData` is an open question and subject of further
/// research.
public actor DataCache<Model: Equatable> {
    /// The data held by this data cache.
    @inlinable
    @Published public private(set) var value: Model

    public init(value: Model) {
        self._value = Published(initialValue: value)
    }

    /// Atomically update the whole data cache. Use this method if you need
    /// to perform number of changes at once.
    @inlinable
    public func update(with value: Model) {
        guard value != self.value else { return }
        self.value = value
    }

    /// Atomically update one variable.
    ///
    /// - ToDo: Investigate whether we can use variadic generics to improve the API.
    /// No change is emmited when the value is the same.
    @inlinable
    public func update<T: Equatable>(_ keyPath: WritableKeyPath<Model, T>, with value: T) {
        guard value != self.value[keyPath: keyPath] else { return }
        self.value[keyPath: keyPath] = value
    }
}
