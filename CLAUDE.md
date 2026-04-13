# CLAUDE.md

## Project

FuturedKit — SwiftUI state management tools, resources and views by Futured.
Repo: https://github.com/futuredapp/FuturedKit

## Build & Test

```bash
# Build (requires Xcode, not standalone swift build due to UIKit/SwiftUI dependencies)
xcodebuild -scheme FuturedHelpers -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -skipMacroValidation build

# Test (all tests are in FuturedKitTests, run via the package scheme)
xcodebuild -scheme FuturedKit-Package -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -skipMacroValidation test
```

`-skipMacroValidation` is needed because the project depends on `futured-macros` which requires macro trust approval.

## Package Structure

Swift 6.1, strict concurrency. Platforms: iOS 17+, macOS 14+, watchOS 10+, tvOS 17+.

Two library targets:
- **FuturedArchitecture** — core architecture types (Coordinator, NavigationStackFlow, TabViewFlow, ComponentModel, DataCache, AlertModel)
  - Depends on: `futured-macros` (FuturedMacros)
- **FuturedHelpers** — non-mandatory extensions and views (TextStyle, Font extensions, SceneDelegate, CoordinatorSceneFlowProvider)
  - Depends on: FuturedArchitecture

Test target: **FuturedKitTests** (tests both targets)

## Architecture Patterns

- All architectural types use `@MainActor` isolation by default
- Reactive state uses `@Observable` macro (not Combine — zero Combine usage in source)
- **ComponentModel** — `@MainActor` protocol; conforming types must be `@Observable`, retained via `@State` in their Component (View). Child components receive model as a plain property (not wrapped). User interactions forwarded as simple function calls. Events passed to coordinators via `onEvent` closure.
- **Coordinator** — `@MainActor @Observable` class hierarchy: base `Coordinator` → `TabCoordinator` (adds `selectedTab`) / `NavigationStackCoordinator` (adds `path: [Destination]`). Controls navigation in response to ComponentModel events.
- **NavigationStackFlow / TabViewFlow** — generic SwiftUI containers that bind to coordinator state, handle modals via `.sheet()` / `.fullScreenCover()`
- **Flow Providers** — encapsulate reusable sub-flows shared across multiple coordinators
- **DataCache** — `@Observable @MainActor` class, single source of truth for shared data; all reads/writes are synchronous from MainActor context. ComponentModels use computed properties to derive data (observation tracking is automatic).
- **Container** — app-level pattern (not a concrete type in this library); a class holding shared dependencies (DataCache, Services). Created at app root, passed to each Coordinator. Uses `listeningTask` to co-locate side effects reacting to cache changes.
- **Services** — encapsulate business logic (networking, data processing) using async/await; update DataCache with results
- Observation subscriptions use `withObservationTracking` in Task loops (not AsyncStream)

### Macros (from futured-macros)

- **`@EnumIdentable`** — auto-conforms enums to `Identifiable`; used on coordinator `Destination` enums marked `nonisolated`
- **`@ProxyMembers`** — generates dynamic member lookup forwarding to reduce boilerplate

## Code Style

- Swift 6.1 strict concurrency
- UIKit-dependent code is gated with `#if canImport(UIKit)`
- Public types have doc comments with `/// Overview` sections
- No third-party formatting tools — follow existing style in the file you're editing
