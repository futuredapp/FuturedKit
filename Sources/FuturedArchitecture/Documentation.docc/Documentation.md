# FuturedKit

The FuturedKit Architecture is a flow-coordinator, component, component model based architecture. The architecture uses Swift Concurrency and the `@Observable` macro for state management.

## Main concepts

This architecture uses some concepts which may be familiar, but we decided to modify the usual naming (mainly due to naming conflits with existing APIs).

![overview](Images/archoverview.svg)

### Scene

*Scene* is the basic building block of the architecture and comprises of two main building blocks: `Component` and `ComponentModel`.

- `Component` is a struct conforming to ``SwiftUI.View``. It has generic parameter `Model` which is used to represent the `ComponentModel` of this scene. The `model` is retained using `@State` property wrapper (since ComponentModels are `@Observable` classes).
- `ComponentModel` consists of three parts: `ComponentModelProtocol`, `MockComponentModel` and the `ComponentModel` itself. We use this decomposition so we can create mocked component model for better SwiftUI Previews experience.
  - `ComponentModelProtocol` defines the properties required by the `Component`. It also defines functions, which the `Component` may call in response to an event, such as a button tap. All `ComponentModelProtocol` are required to extend the ``ComponentModel`` protocol.
  - `MockComponentModel` should be only used in debug builds (use `#if DEBUG`) and as compact as possible to allow for responsive SwiftUI Previews.
  - `ComponentModel` is the implementation of `ComponentModelProtocol` and is responsible for storing the data, sending events to the ``Coordinator`` and subscribing to changes which may be relevant for this scene. ComponentModels should be annotated with `@Observable` macro.

### Flow Coordinator

*Flow Coordinator* is a class which manages creation, lifetime and data flows in child-scenes of a container (such as Navigation or Tab). A *flow coordinator* may be also looked upon as a "view model of a container view." All coordinators are required to conform to ``Coordinator`` protocol, but we provide implementations for the most commonly used containers:

 - ``NavigationStackCoordinator`` and associated view ``NavigationStackFlow`` is used for Navigation.
 - ``TabCoordinator`` and associated view ``TabViewFlow`` is used for Tabs.

Flow coordinators are also responsible for presentation of modal views.

### Container

Container is not defined as a type or a protocol, but is a part of the architecture. It is used for dependency management. In essence, *container* is only required to be an instance of a class, hold references to all globally accessible instances (for example Services). 

### Data Cache

`DataCache` is a `@MainActor` `@Observable` class holding an equatable model struct. Because it shares the main actor with coordinators and component models, all reads and writes are synchronous. Observation is automatic: any `@Observable` context that reads `dataCache.value` will re-evaluate when it changes. Use `update(with:)`, `update(_:with:)`, and `populate(_:with:)` to mutate the cache.

Each application should have one global data cache stored in the `Container`. Individual Coordinators may have their own private Data Caches to coordinate data flows across child scenes.

#### 1. Computed properties (display) — primary pattern

Derive display state from the cache using computed properties. `@Observable` tracks reads through the entire chain — SwiftUI views reading these properties automatically re-evaluate when the underlying cache value changes. **Do not copy cache values into stored properties**; that creates a one-time snapshot that won't reflect later changes (e.g. when a modal adds or modifies an item).

```swift
var items: [Item] {
    dataCache.value.items
}
var userName: String {
    dataCache.value.user.name
}
```

Use `onAppear` for fetching fresh data from the network or subscribing to cache changes (see below) — not for copying cache state.

#### 2. Imperative observation (side effects)

When a component model needs to react to cache changes programmatically (not for display), use `withObservationTracking` in a Task loop. Concrete use cases include:

- triggering a network re-fetch when a related cache value changes,
- firing an analytics event on state transition,
- performing navigation based on cache state.

```swift
func onAppear() async {
    while !Task.isCancelled {
        await withCheckedContinuation { continuation in
            withObservationTracking {
                processModel(dataCache.value)
            } onChange: {
                continuation.resume()
            }
        }
    }
}
```

This is the standard Swift pattern for imperative observation and does not require any infrastructure in `DataCache` itself.

#### 3. Observations + removeDuplicates() (iOS 26+)

From iOS 26+ / macOS 26+, `Observations` (an `AsyncSequence` from Swift 6.2) replaces the manual `withObservationTracking` + `withCheckedContinuation` loop with cleaner "did set" semantics. Combined with [`AsyncAlgorithms`](https://github.com/apple/swift-async-algorithms)' `.removeDuplicates()`, it also provides per-property filtering similar to what Combine's `.map(\.prop).removeDuplicates()` offered:

```swift
// Requires: import AsyncAlgorithms, iOS 26+ / macOS 26+
for await items in Observations({ dataCache.value.items }).removeDuplicates() {
    processItems(items)   // fires only when items actually changed
}
```

#### Observation granularity

`@Observable` tracks at the stored property level. `DataCache` has one stored property — `value`. All computed properties that read `dataCache.value` (regardless of which sub-property) re-evaluate when *any* part of the model changes. For SwiftUI views this is fine — body re-evaluation is cheap and SwiftUI diffs the output. For imperative subscriptions, add manual deduplication or use `Observations` + `.removeDuplicates()` on iOS 26+ (see above).

### Flow Provider

Flow providers are optional part of the architecture. It may be used to encapsulate parts of a flow, which may be used in number of coordinators. For more information, visit ``CoordinatorSceneFlowProvider`` and related template.

## Data Flows

The idea behind data flows in the Architecture is fairly simple: use closures when talking to a parent, arguments when passing immutable data from parent to a child and `@Observable` properties when data passed from parent to a child is subject to change. Below are described some suggestions on how to implement data flows for certain scenarios.

### Component <-> Component Model

### Component Model <-> Coordinator

### Component Model <-> Component Model

### Component Model -> Component Model using navigation

### Persisted data models

Data Flow for persisted data is an open issue.
