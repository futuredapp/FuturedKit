import SwiftUI

/// The `TabViewFlow` encapsulates the ``SwiftUI.TabView`` and binds it to the
/// variables and callbacks of the ``TabCoordinator`` which it retains as a ``SwiftUI.State``.
/// - Experiment: This API is in preview and subject to change.
public struct TabViewFlow<Coordinator: TabCoordinator, Content: View>: View {
    @State private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content
    @Namespace private var zoomNamespace

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as ``SwiftUI.State``
    ///   - content: The definition of tabs held by this TabView should be placed into this ViewBuilder. You are required to use instances of `Tab`
    ///   type as tags of the views. For an example refer to the template.
    public init(coordinator: Coordinator, @ViewBuilder content: @MainActor @escaping () -> Content) {
        self._coordinator = State(wrappedValue: coordinator)
        self.content = content
    }

    #if os(macOS)
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
    }
    #else
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .environment(\.zoomNamespace, zoomNamespace)
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss) { destination in
            if let sourceID = coordinator.modalCover?.zoomSourceID {
                coordinator.scene(for: destination)
                    .navigationTransition(.zoom(sourceID: sourceID, in: zoomNamespace))
            } else {
                coordinator.scene(for: destination)
            }
        }
    }
    #endif

    private var sheetBinding: Binding<Coordinator.Destination?> {
        .init {
            coordinator.modalCover?.style == .sheet ? coordinator.modalCover?.destination : nil
        } set: { destination in
            coordinator.modalCover = destination.map { .init(destination: $0, style: .sheet) }
        }
    }

    #if !os(macOS)
    private var fullscreenCoverBinding: Binding<Coordinator.Destination?> {
        .init {
            coordinator.modalCover?.style == .fullscreenCover ? coordinator.modalCover?.destination : nil
        } set: { destination in
            coordinator.modalCover = destination.map { .init(destination: $0, style: .fullscreenCover) }
        }
    }
    #endif
}
