import SwiftUI

/// The `NavigationStackFlow` encapsulates the ``SwiftUI.NavigationStack`` and binds it to the
/// variables and callbacks of the ``NavigationStackCoordinator`` which is retains as a ``SwiftUI.StateObject``.
public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// Use in case when modal views presented by this coordinator should have detents.
    @State private var modalDetents: Set<PresentationDetent>?

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as the ``SwiftUI.StateObject``
    ///   - content: The root view of this navigation stack. The ``navigationDestination(for:destination:)`` modifier
    ///   is applied to this content.
    public init(coordinator: @autoclosure @escaping () -> Coordinator, content: @MainActor @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    #if os(macOS)
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
        }
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
    }
    #else
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
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

extension View {
    func readSize(_ action: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { action(proxy.size) }
                    .onChange(of: proxy.size) { action($0) }
            }
        )
    }
}
