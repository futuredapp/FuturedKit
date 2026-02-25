import Foundation

/// `DataCache` stores shared mutable state that can be read by multiple components
/// and/or fetched from remote.
///
/// Because `DataCache` is `@MainActor`, all reads and writes are synchronous from any
/// `@MainActor` context (coordinators, component models).
///
/// Observation is handled by the `@Observable` macro: any `@Observable` or SwiftUI
/// context that reads `dataCache.value` (or a keyPath of it) will automatically
/// re-evaluate when the value changes.
///
/// Mutate the cache only via the provided `update` and `populate` methods.
/// As a general rule, value types should be used as the `Model`.
///
/// An application should contain one shared application-wide cache stored in the
/// `Container`, but each coordinator may also create a private data cache.
@Observable
@MainActor
public final class DataCache<Model: Equatable & Sendable> {

    /// The data held by this data cache.
    public private(set) var value: Model

    public init(value: Model) {
        self.value = value
    }

    /// Replace the whole model. Use this method when you need to update multiple
    /// properties at once. No-op if the value is unchanged.
    public func update(with value: Model) {
        guard value != self.value else { return }
        self.value = value
    }

    /// Replace one property via keyPath. No-op if the value is unchanged.
    public func update<T: Equatable>(_ keyPath: WritableKeyPath<Model, T>, with value: T) {
        guard value != self.value[keyPath: keyPath] else { return }
        self.value[keyPath: keyPath] = value
    }

    /// Merge a collection by Identifiable identity.
    ///
    /// - Existing items whose ID appears in `newItems` are updated in place (order preserved).
    /// - Items in `newItems` whose ID is absent from the current collection are appended.
    /// - Items already in the collection but absent from `newItems` are kept unchanged.
    /// - No write occurs when the merged result is equal to the current collection.
    public func populate<T>(
        _ keyPath: WritableKeyPath<Model, T>,
        with newItems: T
    ) where T: RangeReplaceableCollection & MutableCollection, T.Element: Identifiable & Equatable {
        guard !newItems.isEmpty else { return }
        let original = self.value[keyPath: keyPath]
        var current = original
        let newItemsDict = Dictionary(uniqueKeysWithValues: newItems.map { ($0.id, $0) })
        let existingIds = Set(original.map(\.id))

        for i in current.indices {
            if let updated = newItemsDict[current[i].id] {
                current[i] = updated
            }
        }
        current.append(contentsOf: newItems.filter { !existingIds.contains($0.id) })

        guard !current.elementsEqual(original) else { return }
        self.value[keyPath: keyPath] = current
    }

    /// Optional-collection variant of `populate(_:with:)`.
    public func populate<T>(
        _ keyPath: WritableKeyPath<Model, T?>,
        with newItems: T
    ) where T: RangeReplaceableCollection & MutableCollection, T.Element: Identifiable & Equatable {
        guard !newItems.isEmpty else { return }
        let original = self.value[keyPath: keyPath] ?? T()
        var current = original
        let newItemsDict = Dictionary(uniqueKeysWithValues: newItems.map { ($0.id, $0) })
        let existingIds = Set(original.map(\.id))

        for i in current.indices {
            if let updated = newItemsDict[current[i].id] {
                current[i] = updated
            }
        }
        current.append(contentsOf: newItems.filter { !existingIds.contains($0.id) })

        guard !current.elementsEqual(original) else { return }
        self.value[keyPath: keyPath] = current
    }
}
