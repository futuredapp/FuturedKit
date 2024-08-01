import SwiftUI

public protocol Coordinator: ObservableObject {
    associatedtype Destination: Hashable & Identifiable
    associatedtype RootView: View
    associatedtype DestinationViews: View

    /// `rootView` returns the coordinator's main view. Maintain its purity by defining only the view, without added logic or modifiers.
    /// If logic or modifiers are needed, encapsulate them in a separate view that can accommodate necessary dependencies.
    /// Skipping this recommendation may prevent UI updates when changing `@Published` properties, as `rootView` is static.
    @ViewBuilder
    static func rootView(with instance: Self) -> RootView

    var modalCover: ModalCoverModel<Destination>? { get set }

    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews
    func onSheetDismiss()
    #if !os(macOS)
    func onFullscreenCoverDismiss()
    #endif
}

public extension Coordinator {
    func present(sheet: Destination) {
        Task { @MainActor in
            self.sheet = sheet
        }
    }

    func dismissSheet() {
        Task { @MainActor in
            self.sheet = nil
        }
    }

    func onSheetDismiss() {}

    var sheet: Destination? {
        get { modalCover?.style == .sheet ? modalCover?.destination : nil }
        set { modalCover = newValue.map { ModalCoverModel(destination: $0, style: .sheet) } }
    }

    var fullscreenCover: Destination? {
        get { modalCover?.style == .fullscreenCover ? modalCover?.destination : nil }
        set { modalCover = newValue.map { ModalCoverModel(destination: $0, style: .fullscreenCover) } }
    }
}

#if !os(macOS)
public extension Coordinator {
    func present(fullscreenCover: Destination) {
        Task { @MainActor in
            self.fullscreenCover = fullscreenCover
        }
    }

    func dismissFullscreenCover() {
        Task { @MainActor in
            self.fullscreenCover = nil
        }
    }

    func onFullscreenCoverDismiss() {}
}
#endif

public protocol TabCoordinator: Coordinator {
    associatedtype Tab: Hashable

    var selectedTab: Tab { get set }
}

public protocol NavigationStackCoordinator: Coordinator {
    var path: [Destination] { get set }
}

public extension NavigationStackCoordinator {
    func navigate(to destination: Destination) {
        Task { @MainActor in
            self.path.append(destination)
        }
    }

    func pop() {
        Task { @MainActor in
            self.path.removeLast()
        }
    }

    func pop(to destination: Destination?) {
        Task { @MainActor in
            let index = destination.flatMap(self.path.lastIndex(of:)) ?? self.path.startIndex
            self.path = Array(path[path.startIndex...index])
        }
    }
}
