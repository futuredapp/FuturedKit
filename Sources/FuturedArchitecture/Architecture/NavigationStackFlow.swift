import SwiftUI

public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    public init(coordinator: @autoclosure @escaping () -> Coordinator, content: @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    #if os(macOS)
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onSheetDismiss, content: coordinator.scene(for:))
    }
    #else
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
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

    private var fullscreenCoverBinding: Binding<Coordinator.Destination?> {
        .init {
            coordinator.modalCover?.style == .fullscreenCover ? coordinator.modalCover?.destination : nil
        } set: { destination in
            coordinator.modalCover = destination.map { .init(destination: $0, style: .fullscreenCover) }
        }
    }
}
