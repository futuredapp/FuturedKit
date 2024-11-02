import SwiftUI

/// The `TabViewFlow` encapsulates the ``SwiftUI.TabView`` and binds it to the
/// variables and callbacks of the ``TabCoordinator`` which is retains as a ``SwiftUI.StateObject``.
/// - Experiment: This API is in preview and subjet to change.
public struct TabViewFlow<Coordinator: TabCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// Use in case when modal views presented by this coordinator should have detents.
    @State private var modalDetents: Set<PresentationDetent>?

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as the ``SwiftUI.StateObject``
    ///   - content: The definition of tabs held by this TabView should be placed into this ViewBuilder. You are required to use instances of `Tab`
    ///   type as tags of the views. For an example refer to the template.
    public init(coordinator: @autoclosure @escaping () -> Coordinator, @ViewBuilder content: @MainActor @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    #if os(macOS)
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
    }
    #else
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
    }
    #endif

    @ViewBuilder
    private func modalScene(for model: ModalCoverModel<Coordinator.Destination>) -> some View {
        if model.style.hasDetents {
            coordinator.scene(for: model.destination)
                .readSize { modalDetents = model.style.detents(size: $0) }
                .presentationDetents(modalDetents ?? [])
        } else {
            coordinator.scene(for: model.destination)
        }
    }

    private var sheetBinding: Binding<ModalCoverModel<Coordinator.Destination>?> {
        .init {
            coordinator.modalCover?.style.isSheet == true ? coordinator.modalCover : nil
        } set: { _ in
            coordinator.modalCover = nil
        }
    }

    #if !os(macOS)
    private var fullscreenCoverBinding: Binding<ModalCoverModel<Coordinator.Destination>?> {
        .init {
            coordinator.modalCover?.style.isSheet == false ? coordinator.modalCover : nil
        } set: { _ in
            coordinator.modalCover = nil
        }
    }
    #endif
}
