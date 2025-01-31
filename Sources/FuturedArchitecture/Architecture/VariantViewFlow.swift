import SwiftUI

/// The `VariantViewFlow` encapsulates the ``SwiftUI.View`` and binds it to the
/// variables and callbacks of the ``VariantCoordinator`` which is retains as a ``SwiftUI.StateObject``.
/// - Experiment: This API is in preview and subjet to change.
public struct VariantViewFlow<Coordinator: VariantCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    /// - Parameters:
    ///   - coordinator: The instance of the coordinator used as the model and retained as the ``SwiftUI.StateObject``
    ///   - content: The content should contain a single `switch` statement picking a view depending on the state of `selectedTab`.
    public init(coordinator: @autoclosure @escaping () -> Coordinator, @ViewBuilder content: @MainActor @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

#if os(macOS)
    public var body: some View {
        content()
            .sheet(item: sheetBinding, onDismiss: coordinator.onModalDismiss, content: coordinator.scene(for:))
    }
#else
    public var body: some View {
        content()
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
