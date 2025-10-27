import SwiftUI

/// The `NavigationStackFlow` encapsulates the ``SwiftUI.NavigationStack`` and binds it to the
/// variables and callbacks of the ``NavigationStackCoordinator`` which is retains as a ``SwiftUI.StateObject``.
public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// Use in case when whole navigation stack should have detents.
    @State private var navigationDetents: Set<PresentationDetent>?

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
        self.navigationDetents = detents == nil ? nil : Set(detents!.map { $0.detent() })
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
        }
        .modifier(OptionalPresentationDetentsModifier(detents: navigationDetents))
        .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
        #if !os(macOS)
        .fullScreenCover(item: fullscreenCoverBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
        #endif
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

/// A view modifier that conditionally applies presentation detents only when they are non-nil.
/// This prevents overriding child view detents with an empty set when no detents are specified.
private struct OptionalPresentationDetentsModifier: ViewModifier {
    let detents: Set<PresentationDetent>?

    func body(content: Content) -> some View {
        if let detents {
            content.presentationDetents(detents)
        } else {
            content
        }
    }
}
