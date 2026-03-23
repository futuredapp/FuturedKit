import SwiftUI

/// The `TabViewFlow` encapsulates the ``SwiftUI.TabView`` and binds it to the
/// variables and callbacks of the ``TabCoordinator`` which it retains as a ``SwiftUI.State``.
///
/// Uses the legacy `.tabItem` + `.tag` pattern. For iOS 18+ projects that need
/// ``SwiftUI.Tab`` features (e.g. `Tab(role: .search)`), use ``TabContentFlow`` instead.
/// - Experiment: This API is in preview and subject to change.
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
///     Tab("Home", systemImage: "house", value: Tab.home) { ... }
///     Tab(value: Tab.search, role: .search) { ... }
/// }
/// ```
/// - Experiment: This API is in preview and subject to change.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *)
public struct TabContentFlow<Coordinator: TabCoordinator, Content: TabContent<Coordinator.Tab>>: View {
    @State private var coordinator: Coordinator
    @TabContentBuilder<Coordinator.Tab> private let content: () -> Content

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as ``SwiftUI.State``
    ///   - content: The definition of tabs using the ``SwiftUI.Tab`` API.
    public init(coordinator: Coordinator, @TabContentBuilder<Coordinator.Tab> content: @MainActor @escaping () -> Content) {
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

// MARK: - Shared Modal Presentation

/// Shared modifier that adds sheet and full-screen cover presentation to any coordinator-backed view.
struct ModalCoverModifier<C: Coordinator>: ViewModifier {
    var coordinator: C

    private var sheetBinding: Binding<C.Destination?> {
        .init {
            coordinator.modalCover?.style == .sheet ? coordinator.modalCover?.destination : nil
        } set: { destination in
            coordinator.modalCover = destination.map { .init(destination: $0, style: .sheet) }
        }
    }

    #if os(macOS)
    func body(content: Content) -> some View {
        content
            .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
    }
    #else
    private var fullscreenCoverBinding: Binding<C.Destination?> {
        .init {
            coordinator.modalCover?.style == .fullscreenCover ? coordinator.modalCover?.destination : nil
        } set: { destination in
            coordinator.modalCover = destination.map { .init(destination: $0, style: .fullscreenCover) }
        }
    }

    func body(content: Content) -> some View {
        content
            .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
            .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
    }
    #endif
}
