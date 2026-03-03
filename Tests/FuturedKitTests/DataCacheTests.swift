import FuturedArchitecture
import Observation
import Testing

@Suite("DataCache")
@MainActor
struct DataCacheTests {

    private struct Item: Identifiable, Equatable, Sendable {
        let id: Int
        var name: String
    }

    private struct Model: Equatable, Sendable {
        var count: Int
        var items: [Item]
        var optionalItems: [Item]?
    }

    // MARK: update(with:)

    @Test("update(with:) stores the new value")
    func updateSetsValue() {
        let cache = DataCache(value: 1)
        cache.update(with: 2)
        #expect(cache.value == 2)
    }

    @Test("update(with:) is a no-op when the value is unchanged")
    func updateNoOpOnSameValue() {
        let cache = DataCache(value: 1)
        assertNoChange(on: cache) {
            cache.update(with: 1)
        }
    }

    // MARK: update(_:with:)

    @Test("update(_:with:) sets the property at the given keyPath")
    func updateKeyPathSetsProperty() {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: nil))
        cache.update(\.count, with: 5)
        #expect(cache.value.count == 5)
    }

    @Test("update(_:with:) is a no-op when the property value is unchanged")
    func updateKeyPathNoOpOnSameValue() {
        let cache = DataCache(value: Model(count: 5, items: [], optionalItems: nil))
        assertNoChange(on: cache) {
            cache.update(\.count, with: 5)
        }
    }

    // MARK: populate(_:with:)

    @Test("populate does not change the collection when newItems is empty")
    func populateEmptyIsNoOp() {
        let cache = DataCache(value: Model(count: 0, items: [Item(id: 1, name: "A")], optionalItems: nil))
        assertNoChange(on: cache) {
            cache.populate(\.items, with: [Item]())
        }
    }

    @Test("populate appends items whose IDs are not already in the collection")
    func populateAppendsNewItems() {
        let cache = DataCache(value: Model(count: 0, items: [Item(id: 1, name: "A")], optionalItems: nil))
        cache.populate(\.items, with: [Item(id: 2, name: "B"), Item(id: 3, name: "C")])
        #expect(cache.value.items.count == 3)
        #expect(cache.value.items.map(\.id) == [1, 2, 3])
    }

    @Test("populate into an empty collection appends all new items")
    func populateIntoEmptyCollection() {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: nil))
        cache.populate(\.items, with: [Item(id: 1, name: "A"), Item(id: 2, name: "B")])
        #expect(cache.value.items == [Item(id: 1, name: "A"), Item(id: 2, name: "B")])
    }

    @Test("populate updates an existing item by ID without producing a duplicate")
    func populateUpdatesExistingById() {
        let cache = DataCache(value: Model(count: 0, items: [Item(id: 1, name: "A")], optionalItems: nil))
        cache.populate(\.items, with: [Item(id: 1, name: "Updated")])
        #expect(cache.value.items.count == 1)
        #expect(cache.value.items[0].name == "Updated")
    }

    @Test("populate keeps items that are absent from newItems unchanged")
    func populateKeepsUntouchedItems() {
        let cache = DataCache(value: Model(
            count: 0,
            items: [Item(id: 1, name: "A"), Item(id: 2, name: "B")],
            optionalItems: nil
        ))
        cache.populate(\.items, with: [Item(id: 2, name: "B-updated")])
        #expect(cache.value.items.first { $0.id == 1 }?.name == "A")
        #expect(cache.value.items.first { $0.id == 2 }?.name == "B-updated")
    }

    @Test("populate preserves original order and appends new items at the end")
    func populateOrderPreserved() {
        let cache = DataCache(value: Model(
            count: 0,
            items: [Item(id: 1, name: "A"), Item(id: 2, name: "B")],
            optionalItems: nil
        ))
        cache.populate(\.items, with: [Item(id: 2, name: "B2"), Item(id: 3, name: "C")])
        let result = cache.value.items
        #expect(result[0].id == 1)
        #expect(result[1].id == 2)
        #expect(result[1].name == "B2")
        #expect(result[2].id == 3)
    }

    @Test("populate handles duplicate IDs in newItems without crashing (last wins)")
    func populateDuplicateIdsInNewItems() {
        let cache = DataCache(value: Model(count: 0, items: [Item(id: 1, name: "A")], optionalItems: nil))
        cache.populate(\.items, with: [Item(id: 2, name: "B-first"), Item(id: 2, name: "B-last")])
        #expect(cache.value.items.count == 2)
        #expect(cache.value.items.map(\.id) == [1, 2])
        #expect(cache.value.items.first { $0.id == 2 }?.name == "B-last")
    }

    @Test("populate is a no-op when the merged result is equal to the current collection")
    func populateNoOpWhenAllSame() {
        let items = [Item(id: 1, name: "A"), Item(id: 2, name: "B")]
        let cache = DataCache(value: Model(count: 0, items: items, optionalItems: nil))
        assertNoChange(on: cache) {
            cache.populate(\.items, with: items)
        }
    }

    // MARK: populate(_:with:) — optional variant

    @Test("populate on a nil optional collection initialises it from newItems")
    func populateOptionalFromNil() {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: nil))
        cache.populate(\.optionalItems, with: [Item(id: 1, name: "A"), Item(id: 2, name: "B")])
        #expect(cache.value.optionalItems == [Item(id: 1, name: "A"), Item(id: 2, name: "B")])
    }

    @Test("populate updates an existing item by ID in a non-nil optional collection")
    func populateOptionalUpdatesExistingById() {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: [Item(id: 1, name: "A")]))
        cache.populate(\.optionalItems, with: [Item(id: 1, name: "Updated")])
        #expect(cache.value.optionalItems?.count == 1)
        #expect(cache.value.optionalItems?.first?.name == "Updated")
    }

    @Test("populate on an optional collection is a no-op when the merged result is unchanged")
    func populateOptionalNoOpWhenSame() {
        let items: [Item] = [Item(id: 1, name: "A"), Item(id: 2, name: "B")]
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: items))
        assertNoChange(on: cache) {
            cache.populate(\.optionalItems, with: items)
        }
    }

    // MARK: - Helper

    /// Asserts that `action` does not trigger an observation change on `cache.value`.
    ///
    /// `withObservationTracking` fires `onChange` synchronously on `@MainActor` the moment
    /// a tracked property is written, so the check is immediate and race-free.
    ///
    /// `ChangeDetector` is `@unchecked Sendable` because `onChange` is always dispatched
    /// on `@MainActor` (mutations come from `@MainActor DataCache`), matching the actor
    /// of the test itself — there is no actual concurrent access.
    private final class ChangeDetector: @unchecked Sendable {
        var didChange = false
    }

    private func assertNoChange<M: Equatable & Sendable>(
        on cache: DataCache<M>,
        during action: () -> Void
    ) {
        let detector = ChangeDetector()
        withObservationTracking {
            _ = cache.value
        } onChange: {
            detector.didChange = true
        }
        action()
        #expect(!detector.didChange)
    }
}
