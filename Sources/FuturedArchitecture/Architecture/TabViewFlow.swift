import SwiftUI

/// The `TabViewFlow` encapsulates the ``SwiftUI.TabView`` and binds it to the
/// variables and callbacks of the ``TabCoordinator`` which it retains as a ``SwiftUI.State``.
///
/// Uses the legacy `.tabItem` + `.tag` pattern. For iOS 18+ projects that need
/// ``SwiftUI.Tab`` features (e.g. `Tab(role: .search)`), use ``TabContentFlow`` instead.
/// - Experiment: This API is in preview and subject to change.
@available(iOS, deprecated: 18.0, message: "Use TabContentFlow for the iOS 18+ Tab API.")
@available(macOS, deprecated: 15.0, message: "Use TabContentFlow for the macOS 15+ Tab API.")
@available(tvOS, deprecated: 18.0, message: "Use TabContentFlow for the tvOS 18+ Tab API.")
@available(watchOS, deprecated: 11.0, message: "Use TabContentFlow for the watchOS 11+ Tab API.")
public struct TabViewFlow<Coordinator: TabCoordinator, Content: View>: View {
    @State private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as ``SwiftUI.State``
    ///   - content: The definition of tabs held by this TabView should be placed into this ViewBuilder. You are required to use instances of `Tab`
    ///   type as tags of the views. For an example refer to the template.
    public init(coordinator: Coordinator, @ViewBuilder content: @MainActor @escaping () -> Content) {
        self._coordinator = State(wrappedValue: coordinator)
        self.content = content
    }

    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .modifier(ModalCoverModifier(coordinator: coordinator))
    }
}

// MARK: - TabContentFlow (iOS 18+)

/// A variant of ``TabViewFlow`` that accepts ``SwiftUI.TabContent`` instead of `View`,
/// enabling the iOS 18+ ``SwiftUI.Tab`` API with features like `Tab(role: .search)`.
///
/// Use this instead of ``TabViewFlow`` when you need `Tab(role:)`, customizable tab
/// placement, or other iOS 18+ tab features.
///
/// Usage:
/// ```swift
/// TabContentFlow(coordinator: instance) {
///     Tab("Home", systemImage: "house", value: AppTab.home) { ... }
///     Tab(value: AppTab.search, role: .search) { ... }
/// }
/// ```
/// - Experiment: This API is in preview and subject to change.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
public struct TabContentFlow<Coordinator: TabCoordinator, Content: TabContent<Coordinator.TabValue>>: View {
    @State private var coordinator: Coordinator
    @TabContentBuilder<Coordinator.TabValue> private let content: () -> Content

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as ``SwiftUI.State``
    ///   - content: The definition of tabs using the ``SwiftUI.Tab`` API.
    public init(coordinator: Coordinator, @TabContentBuilder<Coordinator.TabValue> content: @MainActor @escaping () -> Content) {
        self._coordinator = State(wrappedValue: coordinator)
        self.content = content
    }

    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .modifier(ModalCoverModifier(coordinator: coordinator))
    }
}
