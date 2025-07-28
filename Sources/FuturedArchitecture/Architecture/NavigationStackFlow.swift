import SwiftUI

/// The `NavigationStackFlow` encapsulates the ``SwiftUI.NavigationStack`` and binds it to the
/// variables and callbacks of the ``NavigationStackCoordinator`` which is retains as a ``SwiftUI.StateObject``.
public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// Use in case when whole navigation stack should have detents.
    @State private var navigationDetents: Set<PresentationDetent>?

    @State private var selectedDetent: PresentationDetent = .height(1) // placeholder, use smallest detent for opening animation

    /// Use for storing detents of each view in navigation stack
    @State private var _detents: [Coordinator.Destination?: Set<PresentationDetent>] = [:]

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
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
        #if !os(macOS)
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
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
                .animation(nil, value: selectedDetent)
                .readSize { size in
                    // If rootView detents was not set
                    if _detents[nil] == nil {
                        // Calculate rootView detents
                        _detents[nil] = Set(detents.map { $0.detent(size: size) } )
                    }

                    // Set current detents to be rootView detents
                    navigationDetents = _detents[nil]

                    guard selectedDetent != .large, selectedDetent != .medium else {
                        return
                    }

                    // If selected detent was .height, select .height detent for rootView
                    selectedDetent = navigationDetents?.first { $0 == .height(size.height) } ?? .height(size.height)
                }
                .navigationDestination(for: Coordinator.Destination.self) { destination in
                    coordinator.scene(for: destination)
                        .animation(nil, value: selectedDetent)
                        .readSize { size in
                            // Wait until push animation finish
                            try? await Task.sleep(for: .milliseconds(600))

                            // If child view detents was not set
                            if _detents[destination] == nil {
                                // Calculate child view detents
                                _detents[destination] = Set(detents.map { $0.detent(size: size) })
                            }

                            // Append current detents to detents, we need to keep detents for each pervious view
                            // otherwise animation will not work
                            navigationDetents = _detents[destination]?.union(navigationDetents ?? [])

                            guard selectedDetent != .large, selectedDetent != .medium else {
                                return
                            }

                            // If selected detent was .height, select .height detent for this child view
                            selectedDetent = navigationDetents?.first { $0 == .height(size.height) } ?? .height(size.height)
                        }
                }
        }
        .presentationDetents(navigationDetents ?? [.height(1)], selection: $selectedDetent)
    }

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

extension View {
    func readSize(_ action: @escaping (CGSize) async -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .task { await action(proxy.size) }
            }
        )
    }
}
