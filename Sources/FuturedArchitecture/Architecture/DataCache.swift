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
public actor DataCache<Model: Equatable & Sendable> {

    // MARK: Stored state

    /// The data held by this data cache.
    public private(set) var value: Model

    private var subscribers: [UUID: AsyncStream<Model>.Continuation] = [:]

    // MARK: Init

    public init(value: Model) {
        self.value = value
    }

    deinit {
        for continuation in subscribers.values {
            continuation.finish()
        }
        subscribers.removeAll()
    }

    // MARK: Observation (Swift Concurrency)

    /// Observe changes of the cache value.
    ///
    /// - Parameter skipInitial: When `true`, the returned stream does not yield the current value
    ///   immediately. It only yields subsequent changes.
    ///
    /// This stream yields whenever `value` changes via any of the `update`/`populate` methods.
    ///
    /// Each call creates a new stream ("one stream per subscriber").
    ///
    /// The stream uses `bufferingNewest(1)` because this is "state": consumers typically only care
    /// about the latest value, and we want to avoid unbounded buffering if updates happen faster
    /// than the consumer can process them.
    public func values(skipInitial: Bool = false) -> AsyncStream<Model> {
        let id = UUID()
        return AsyncStream(Model.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
            // Register subscriber inside the actor.
            subscribers[id] = continuation

            // Yield the current value immediately unless the caller asked to skip it.
            if !skipInitial {
                continuation.yield(value)
            }

            continuation.onTermination = { [weak self] _ in
                Task { // Hop back into the actor to remove subscriber.
                    await self?.removeSubscriber(id: id)
                }
            }
        }
    }

    // MARK: Updates

    /// Atomically update the whole data cache. Use this method if you need
    /// to perform number of changes at once.
    public func update(with value: Model) {
        guard value != self.value else { return }
        self.value = value
        broadcast(self.value)
    }

    /// Atomically update one variable.
    ///
    /// - ToDo: Investigate whether we can use variadic generics to improve the API.
    /// No change is emitted when the value is the same.
    public func update<T: Equatable>(_ keyPath: WritableKeyPath<Model, T>, with value: T) {
        guard value != self.value[keyPath: keyPath] else { return }
        self.value[keyPath: keyPath] = value
        broadcast(self.value)
    }

    /// Populate one variable of Collection type.
    /// - Description: The method will append new elements to the existing collection. The elements which are already
    /// in the collection as well as in the new collection will be updated. No change is emitted when the new collection is empty
    /// or when the merged result is the same as the current value.
    public func populate<T>(
        _ keyPath: WritableKeyPath<Model, T>,
        with newItems: T
    ) where T: RangeReplaceableCollection, T.Element: Equatable {
        guard !newItems.isEmpty else { return }
        let current = self.value[keyPath: keyPath]
        let merged = mergedCollection(current: current, newItems: newItems)
        guard !current.elementsEqual(merged) else { return }
        self.value[keyPath: keyPath] = merged
        broadcast(self.value)
    }

    /// Populate one optional variable of Collection type.
    ///
    /// - Description: The method will append new elements to the existing collection. The elements which are already
    /// in the collection as well as in the new collection will be updated. No change is emitted when the new collection is empty
    /// or when the merged result is the same as the current value.
    public func populate<T>(
        _ keyPath: WritableKeyPath<Model, T?>,
        with newItems: T
    ) where T: RangeReplaceableCollection, T.Element: Equatable {
        guard !newItems.isEmpty else { return }
        let current = self.value[keyPath: keyPath] ?? T()
        let merged = mergedCollection(current: current, newItems: newItems)
        guard !current.elementsEqual(merged) else { return }
        self.value[keyPath: keyPath] = merged
        broadcast(self.value)
    }

    // MARK: Private Helpers

    private func removeSubscriber(id: UUID) {
        subscribers[id]?.finish()
        subscribers[id] = nil
    }

    private func broadcast(_ value: Model) {
        for continuation in subscribers.values {
            continuation.yield(value)
        }
    }

    private func mergedCollection<T>(
        current: T,
        newItems: T
    ) -> T where T: RangeReplaceableCollection, T.Element: Equatable {
        var result = T()
        result.reserveCapacity(current.count + newItems.count)

        let filteredExisting = current.filter { existingItem in
            !newItems.contains(existingItem)
        }
        result.append(contentsOf: filteredExisting)
        result.append(contentsOf: newItems)

        return result
    }
}
