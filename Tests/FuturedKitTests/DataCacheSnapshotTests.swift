#if canImport(Observation)
import FuturedArchitecture
import Observation
import Testing

@Suite("DataCacheSnapshot")
struct DataCacheSnapshotTests {

    @Test("Snapshot initializes from cache current value")
    func snapshotInitializesFromCache() async throws {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let cache = DataCache(value: 1)
        let snapshot = await DataCacheSnapshot(cache: cache)
        let value = await Task { @MainActor in
            snapshot.value
        }.value
        #expect(value == 1)
    }

    @Test("startObserving(skipInitial: true) updates snapshot on changes")
    func snapshotObservesChangesSkipInitial() async throws {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let cache = DataCache(value: 1)
        let snapshot = await DataCacheSnapshot(cache: cache)

        await Task { @MainActor in
            await snapshot.startObserving(skipInitial: true)
        }.value
        await cache.update(with: 2)

        try? await Task.sleep(for: .seconds(0.1))
        let value = await Task { @MainActor in
            snapshot.value
        }.value
        #expect(value == 2)

        await Task { @MainActor in
            snapshot.stopObserving()
        }.value
    }

    @Test("startObserving(skipInitial: false) yields the current cache value immediately")
    func snapshotObservesInitialValueWhenSkipInitialIsFalse() async throws {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let cache = DataCache(value: 1)

        // Use a sentinel value (999) so we can prove the initial stream emission happened.
        // If `skipInitial: false` works, the snapshot should change from 999 -> 1 without any cache update.
        let snapshot = await Task { @MainActor in
            DataCacheSnapshot(cache: cache, initialValue: 999)
        }.value

        await Task { @MainActor in
            await snapshot.startObserving(skipInitial: false)
        }.value

        try? await Task.sleep(for: .seconds(0.1))
        let value = await Task { @MainActor in
            snapshot.value
        }.value
        #expect(value == 1)

        await Task { @MainActor in
            snapshot.stopObserving()
        }.value
    }

    @Test("stopObserving prevents further updates")
    func snapshotStopObserving() async throws {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let cache = DataCache(value: 1)
        let snapshot = await DataCacheSnapshot(cache: cache)

        await Task { @MainActor in
            await snapshot.startObserving(skipInitial: true)
        }.value
        await cache.update(with: 2)

        try? await Task.sleep(for: .seconds(0.1))
        let first = await Task { @MainActor in
            snapshot.value
        }.value
        #expect(first == 2)

        await Task { @MainActor in
            snapshot.stopObserving()
        }.value
        await cache.update(with: 3)

        try? await Task.sleep(for: .seconds(0.1))
        let second = await Task { @MainActor in
            snapshot.value
        }.value
        #expect(second == 2)
    }

    @Test("Snapshot can be deallocated after stopping observation (no obvious retain cycle)")
    func snapshotDeallocatesAfterStopObserving() async throws {
        guard #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, *) else { return }

        let cache = DataCache(value: 1)
        weak var weakSnapshot: DataCacheSnapshot<Int>?

        do {
            let snapshot = await DataCacheSnapshot(cache: cache)
            weakSnapshot = snapshot
            await Task { @MainActor in
                await snapshot.startObserving(skipInitial: true)
                snapshot.stopObserving()
            }.value
        }

        try? await Task.sleep(for: .seconds(0.1))
        #expect(weakSnapshot == nil)
    }
}

#endif
