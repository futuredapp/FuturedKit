import SwiftUI

/// The `NavigationStackFlow` encapsulates the ``SwiftUI.NavigationStack`` and binds it to the
/// variables and callbacks of the ``NavigationStackCoordinator`` which is retains as a ``SwiftUI.StateObject``.
public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// Use in case when modal views presented by this coordinator should have detents.
    @State private var modalDetents: Set<PresentationDetent>?

    /// Use in case when whole navigation stack should have detents.
    @State private var navigationDetents: Set<PresentationDetent>?

    private let detents: Set<SheetDetent>?

    /// - Parameters:
    ///   - detents: The set of detents which should be applied to the whole navigation stack.
    ///   - coordinator: The instance of the coordinator used as the model and retained as the ``SwiftUI.StateObject``
    ///   - content: The root view of this navigation stack. The ``navigationDestination(for:destination:)`` modifier
    ///   is applied to this content.
    public init(
        detents: Set<SheetDetent>? = nil,
        coordinator: @autoclosure @escaping () -> Coordinator,
        content: @MainActor @escaping () -> Content
    ) {
        self.detents = detents
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    public var body: some View {
        Group {
            if let detents {
                body(with: detents)
            } else {
                bodyWithoutSupportOfDetents
            }
        }
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
        #if !os(macOS)
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: modalScene(for:))
        #endif
    }

    private var bodyWithoutSupportOfDetents: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
        }
    }

    private func body(with detents: Set<SheetDetent>) -> some View {
        NavigationStack(path: $coordinator.path) {
            content()
                .readSize { size in
                    navigationDetents = Set(detents.map { $0.detent(size: size) } )
                }
                .navigationDestination(for: Coordinator.Destination.self) { destination in
                    coordinator.scene(for: destination)
                        .readSize { size in
                            // TODO: When detents contains .height there is a weird animation
                            navigationDetents = Set(detents.map { $0.detent(size: size) } )
                        }
                }
        }
        .presentationDetents(navigationDetents ?? [])
    }

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
