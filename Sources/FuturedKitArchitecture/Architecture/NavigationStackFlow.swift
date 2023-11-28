import SwiftUI

public struct NavigationStackFlow<Coordinator: NavigationStackCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    public init(coordinator: Coordinator, content: @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator)
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content().navigationDestination(for: Coordinator.Destination.self, destination: coordinator.scene(for:))
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onSheetDismiss, content: coordinator.scene(for:))
        .alert(model: $coordinator.alertModel)
    }
}
