import SwiftUI

/// The `TabViewFlow` encapsulates the ``SwiftUI.TabView`` and binds it to the
/// variables and callbacks of the ``TabCoordinator`` which is retains as a ``SwiftUI.StateObject``.
/// - Experiment: This API is in preview and subjet to change.
public struct TabViewFlow<Coordinator: TabCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as the ``SwiftUI.StateObject``
    ///   - content: The definition of tabs held by this TabView should be placed into this ViewBuilder. You are required to use instances of `Tab`
    ///   type as tags of the views. For an example refer to the template.
    public init(coordinator: @autoclosure @escaping () -> Coordinator, @ViewBuilder content: @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
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
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
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
