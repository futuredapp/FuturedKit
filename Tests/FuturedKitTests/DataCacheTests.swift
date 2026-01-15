import FuturedArchitecture
import Testing

@Suite("DataCache")
struct DataCacheTests {

    private struct Model: Equatable, Sendable {
        var count: Int
        var items: [Int]
        var optionalItems: [Int]?
    }

    @Test("values(skipInitial: false) yields the initial value immediately")
    func valuesEmitsInitialValue() async throws {
        let cache = DataCache(value: 1)

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        let first = await iterator.next()
        #expect(first == 1)
    }

    @Test("values(skipInitial: true) first yielded element is the first update")
    func valuesSkipInitialYieldsOnFirstChange() async throws {
        let cache = DataCache(value: 1)

        let stream = await cache.values(skipInitial: true)
        var iterator = stream.makeAsyncIterator()
        await cache.update(with: 2)

        let first = await iterator.next()
        #expect(first == 2)
    }

    @Test("update(with:) does not emit when value is unchanged (next emission is the later different value)")
    func updateDoesNotEmitOnSameValue() async throws {
        let cache = DataCache(value: 1)

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        // Consume initial
        _ = await iterator.next()

        // Same value should not emit
        await cache.update(with: 1)

        // Different value should emit next
        await cache.update(with: 2)

        let next = await iterator.next()
        #expect(next == 2) // If the same-value update emitted, next would be 1 (or not 2).
    }

    @Test("update(keyPath:with:) emits when the property changes")
    func updateKeyPathEmits() async throws {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: nil))

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        // Consume initial
        _ = await iterator.next()

        await cache.update(\.count, with: 1)
        let next = await iterator.next()
        let unwrapped = try #require(next)
        #expect(unwrapped.count == 1)
    }

    @Test("populate(collection) does not emit when passed an empty collection")
    func populateEmptyDoesNotEmit() async throws {
        let cache = DataCache(value: Model(count: 0, items: [1], optionalItems: nil))

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        // Consume initial
        _ = await iterator.next()

        // Empty should not emit…
        await cache.populate(\.items, with: [Int]())

        // …but a real populate should.
        await cache.populate(\.items, with: [2])

        let next = await iterator.next()
        let unwrapped = try #require(next)
        #expect(unwrapped.items.contains(1) == true)
        #expect(unwrapped.items.contains(2) == true)
    }

    @Test("populate(collection) emits and appends new elements")
    func populateEmitsAndAppends() async throws {
        let cache = DataCache(value: Model(count: 0, items: [1], optionalItems: nil))

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        // Consume initial
        _ = await iterator.next()

        await cache.populate(\.items, with: [2, 3])

        let next = await iterator.next()
        let unwrapped = try #require(next)
        #expect(unwrapped.items.contains(1) == true)
        #expect(unwrapped.items.contains(2) == true)
        #expect(unwrapped.items.contains(3) == true)
    }

    @Test("populate(optional collection) emits when optional is nil and collection is non-empty")
    func populateOptionalEmitsFromNil() async throws {
        let cache = DataCache(value: Model(count: 0, items: [], optionalItems: nil))

        let stream = await cache.values(skipInitial: false)
        var iterator = stream.makeAsyncIterator()

        // Consume initial
        _ = await iterator.next()

        await cache.populate(\.optionalItems, with: [1, 2])

        let next = await iterator.next()
        let unwrapped = try #require(next)
        #expect(unwrapped.optionalItems == [1, 2])
    }

    @Test("values() creates a new stream per subscriber: two subscribers both receive the same update")
    func valuesCreatesNewStreamPerSubscriber() async throws {
        let cache = DataCache(value: 0)

        let streamA = await cache.values(skipInitial: false)
        let streamB = await cache.values(skipInitial: false)

        var iteratorA = streamA.makeAsyncIterator()
        var iteratorB = streamB.makeAsyncIterator()

        // Each stream yields initial value independently.
        let valueA0 = await iteratorA.next()
        let valueB0 = await iteratorB.next()
        #expect(valueA0 == 0)
        #expect(valueB0 == 0)

        // One update should be delivered to BOTH subscribers.
        await cache.update(with: 1)

        let valueA1 = await iteratorA.next()
        let valueB1 = await iteratorB.next()
        #expect(valueA1 == 1)
        #expect(valueB1 == 1)
    }
}
