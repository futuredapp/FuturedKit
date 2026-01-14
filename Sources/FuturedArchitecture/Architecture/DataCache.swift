import Foundation

/// `DataCache` is intended to store state which may be used by
/// more than one *component* and/or fetched from remote.
///
/// An Application should contain one shared application-wide cache, but each
/// coordinator may also create a private data cache.
///
/// The data from data cache should be taken as a subscription and modified
/// only via provided `update` methods. As a general rule, value types should
/// be used as a `Model`.
///
/// - Experiment: This API is in preview and subject to change.
/// - ToDo: How the `DataCache` may interact with persistence such as
/// `CoreData` or `SwiftData` is an open question and subject of further
/// research.
public actor ActorDataCache<Model: Equatable> {
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
    /// No change is emitted when the value is the same.
    @inlinable
    public func update<T: Equatable>(_ keyPath: WritableKeyPath<Model, T>, with value: T) {
        guard value != self.value[keyPath: keyPath] else { return }
        self.value[keyPath: keyPath] = value
    }

    /// Populate one variable of Collection type.
    ///  - Description: The method will append new elements to the existing collection. The elements which are already in the collection as well as in the new collection will be updated. No change is emmited when the new collection is empty.
    @inlinable
    public func populate<T: Collection>(_ keyPath: WritableKeyPath<Model, T>, with collection: T) where T.Element: Equatable {
        guard !collection.isEmpty else { return }
        var values = self.value[keyPath: keyPath].filter { !collection.contains($0) }
        values.append(contentsOf: collection)
        guard let values = values as? T else {
            assertionFailure("Cannot convert back to generic")
            return
        }
        self.value[keyPath: keyPath] = values
    }

    /// Populate one optional variable of Collection type.
    /// - Description: The method will append new elements to the existing collection. The elements which are already in the collection as well as in the new collection will be updated. No change is emmited when the new collection is empty.
    @inlinable
    public func populate<T: Collection>(_ keyPath: WritableKeyPath<Model, T?>, with collection: T) where T.Element: Equatable {
        guard !collection.isEmpty else { return }
        var values = self.value[keyPath: keyPath]?.filter { !collection.contains($0) } ?? []
        values.append(contentsOf: collection)
        guard let values = values as? T else {
            assertionFailure("Cannot convert back to generic")
            return
        }
        self.value[keyPath: keyPath] = values
    }
}
