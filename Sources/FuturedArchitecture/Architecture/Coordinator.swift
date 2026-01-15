import SwiftUI

/// This architecture is modeled around the concept of *Flow Coordinators*. You might think about
/// *flow coordinator* as a "view model for container view." For example, whereas data model of
/// a Table View is stored in a *component model*, data model of ``SwiftUI.TabView`` and ``SwiftUI.NavigationStack``
/// is stored in an instance conforming to `Coordinator`.
///
/// This base `protocol` contains set of common requirements for all coordinators. Other protocols
/// tailored to specific Containers are provided as well.
@MainActor
public protocol Coordinator: ObservableObject {
    /// Type used to represent the state of the container, i.e. which child-components should be presented.
    associatedtype Destination: Hashable & Identifiable
    /// The root view of the coordinator is commonly the container itself.
    associatedtype RootView: View
    /// Views which might be presented by the container based on an instance of `Destination`.
    associatedtype DestinationViews: View

    /// `rootView` returns the coordinator's main view.
    /// - Note: It is common pattern to provide a default "destination" view as the body of the *container* instead of
    /// ``SwiftUI.EmptyView``. If you do so, remember to always capture the `instance` of the *coordinator* weakly!
    /// - Warning: Maintain its purity by defining only the view, without added logic or modifiers.
    /// If logic or modifiers are needed, encapsulate them in a separate view that can accommodate necessary dependencies.
    /// Skipping this recommendation may prevent UI updates when changing `@Published` properties, as `rootView` is static.
    /// - Parameter instance: An instance of `Coordinator` which will be retained by the *container*.
    /// - Returns: The container view.
    @ViewBuilder
    static func rootView(with instance: Self) -> RootView

    /// Modal cover is part of the model of the container. It represents the state of the View covering the container.
    var modalCover: ModalCoverModel<Destination>? { get set }

    /// This function provides an instance of a `View` (commonly a *Component*) for each possible state of the
    /// container (the destination).
    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews

    /// This is a delegate function called when a modal view presented by the *container* is dismissed.
    /// - Note: Default empty implementation is provided.
    func onModalDismiss()
}

public extension Coordinator {
    /// Convenience function for presenting a modal over the *container*.
    /// - Parameters:
    ///   - destination: The description of the desired view passed to the ``scene(for:)`` function
    ///   of the *coordinator*.
    ///   - type: Kind of modal presentation.
    func present(modal destination: Destination, type: ModalCoverModelStyle) {
        switch type {
        case .sheet:
            self.modalCover = .init(destination: destination, style: .sheet)
        #if !os(macOS)
        case .fullscreenCover:
            self.modalCover = .init(destination: destination, style: .fullscreenCover)
        #endif
        }
    }

    /// Convenience method for dismissing a modal.
    func dismissModal() {
        self.modalCover = nil
    }

    func onModalDismiss() {}
}

/// `TabCoordinator` provides additional requirements for the use with ``SwiftUI.TabView``.
/// This *coordinator* is ment to have ``TabViewFlow`` as the Root view.
/// - Experiment: This API is in preview and subject to change.
/// - Todo: ``SwiftUI.TabView`` requires internal state, which is forbidden as per
/// documentation of ``Coordinator.rootView(with:)``. Also, the API introduces `Tab` type
/// which is essentially duplication of `Destination`. Consider, how the API limits the use of tabs.
@MainActor
public protocol TabCoordinator: Coordinator {
    associatedtype Tab: Hashable
    var selectedTab: Tab { get set }
}

/// `NavigationStackCoordinator` provides additional requirements for use with ``SwiftUI.NavigationStack``.
/// This *coordinator* is ment have ``NavigationStackFlow`` as the Root view.
///
/// - ToDo: Create a template for this coordinator.
@MainActor
public protocol NavigationStackCoordinator: Coordinator {
    /// Property modeling the Views currently placed on stack.
    var path: [Destination] { get set }
}

public extension NavigationStackCoordinator {
    /// Convenience function used to add new view to the navigation stack.
    func navigate(to destination: Destination) {
        self.path.append(destination)
    }

    /// Convenience function used to remove topmost view from the navigation stack.
    func pop() {
        self.path.removeLast()
    }

    /// Convenience function used to remove all views from the stack, until the provided destination.
    /// - Parameter destination: Destination to be reached. If nil is passed, or such destination
    /// is not currently on the stack, all views are removed.
    /// - Experiment: This API is in preview and subject to change.
    func pop(to destination: Destination) {
        guard let index = self.path.lastIndex(of: destination) else {
            assertionFailure("Destination not found on the stack")
            return
        }
        self.path = Array(path[path.startIndex...index])
    }

    func popToRoot() {
        path = []
    }

    func reset() {
        path = []
        modalCover = nil
    }
}
