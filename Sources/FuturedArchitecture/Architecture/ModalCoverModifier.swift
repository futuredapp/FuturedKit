import SwiftUI

/// Adds `.sheet` and (on non-macOS platforms) `.fullScreenCover` presentation
/// driven by a ``Coordinator``'s ``Coordinator/modalCover`` state.
///
/// Use this modifier in any flow container view (e.g. ``NavigationStackFlow``,
/// ``TabViewFlow``, ``TabContentFlow``) to keep modal presentation behaviour consistent.
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
