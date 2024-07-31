import SwiftUI

public struct TabViewFlow<Coordinator: TabCoordinator, Content: View>: View {
    @StateObject private var coordinator: Coordinator
    @ViewBuilder private let content: () -> Content

    public init(coordinator: @autoclosure @escaping () -> Coordinator, @ViewBuilder content: @escaping () -> Content) {
        self._coordinator = StateObject(wrappedValue: coordinator())
        self.content = content
    }

    #if os(macOS)
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onSheetDismiss, content: coordinator.scene(for:))
    }
    #else
    public var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            content()
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onSheetDismiss, content: coordinator.scene(for:))
        .fullScreenCover(item: $coordinator.fullscreenCover, onDismiss: coordinator.onFullscreenCoverDismiss, content: coordinator.scene(for:))
    }
    #endif
}
