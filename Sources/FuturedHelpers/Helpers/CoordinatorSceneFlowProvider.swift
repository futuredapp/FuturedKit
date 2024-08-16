//
//  CoordinatorSceneFlowProvider.swift
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftUI

/**
 A protocol to represent navigable destinations in a reusable scene flow

 # Example #
 ```
 protocol TemplateFlowDestination: CoordinatorSceneFlowDestination {
    static var destination: Self { get }
    static var end: Self { get }
 }
 ```
 */
public protocol CoordinatorSceneFlowDestination: Hashable, Identifiable, Equatable {}

/**
 A protocol defining an interface for reusable scene flow providers.
 ```
final class TemplateSceneFlowProvider: CoordinatorSceneFlowProvider {
     let onNavigateToDestination: (Destination) -> Void
     let onPop: () -> Void
     let onPresentSheet: ((Destination) -> Void)? = nil
     let onDismissSheet: (() -> Void)? = nil
     let onPresentFullscreenCover: ((Destination) -> Void)? = nil
     let onDismissFullscreenCover: (() -> Void)? = nil
     let onPopToDestination: ((Destination?) -> Void)? = nil
     let onShowError: ((AppError) -> Void)? = nil

     private let container: BasicCapitalContainer

     init(container: BasicCapitalContainer, onNavigateToDestination: @escaping (Destination) -> Void, onPop: @escaping () -> Void) {
         self.container = container
         self.onNavigateToDestination = onNavigateToDestination
         self.onPop = onPop
     }

     static func rootView(with instance: TemplateSceneFlowProvider) -> some View {
         LearnComponent(
            model: LearnComponentModel(
                dataCache: instance.container.dataCache
            ) { [weak instance] event in
                switch event {
                case .showUnderstandBasicCapital:
                    instance?.navigate(to: .destination)
                }
            }
         )
     }

     func scene(for destination: Destination) -> some View {
         switch destination {
         case .destination:
             Color.red
         case .end:
             EmptyView()
         }
     }

     enum Destination: String, TemplateFlowDestination {
         case destination
         case end

         var id: String {
             rawValue
         }
     }
 }

final class TemplateCoordinator: NavigationStackCoordinator {
    @Published var path: [Destination] = []
    @Published var sheet: Destination?
    @Published var fullscreenCover: Destination?
    @Published var alertModel: AlertModel?

    private let container: BasicCapitalContainer

    private lazy var templateSceneProvider: TemplateSceneFlowProvider = {
        TemplateSceneFlowProvider(container: container, onNavigateToDestination: { [weak self] destination in
            if destination == .end {
                self?.navigate(to: .flowSpecificDestinationAfterEmbededFlow)
            } else {
                self?.navigate(to: destination)
            }
        }, onPop: { [weak self] in
            self?.pop()
        })
    }()

    init(container: BasicCapitalContainer) {
        self.container = container
    }

    static func rootView(with instance: TemplateCoordinator) -> some View {
        NavigationStackFlow(coordinator: instance) {
            SomeSpeficComponent(
                model: SomeSpeficComponentModel(
                    dataCache: instance.container.dataCache
                ) { [weak instance] event in
                    switch event {
                    case .showFlowSpecificDestination:
                        instance?.navigate(to: .flowSpecificDestination)
                    case .showEmbededFlow:
                        instance?.navigate(to: .embededFlow(destination: nil))
                    }
                }
            )
        }
    }

    func scene(for destination: Destination) -> some View {
        switch destination {
        case let .embededFlow(destination):
            embededFlowScenes(destination: destination)
        default:
            FlowSpecificComponent(model: FlowSpecificComponentModel())
        }
    }

    @ViewBuilder
    private func embededFlowScenes(destination: (any TemplateFlowDestination)?) -> some View {
        if let destination = destination as? TemplateSceneFlowProvider.Destination {
            templateSceneProvider.scene(for: destination)
        } else {
            TemplateSceneFlowProvider.rootView(with: templateSceneProvider)
        }
    }

    enum Destination: Hashable, Identifiable {
        case flowSpecificDestination
        case embededFlow(destination: (any TemplateFlowDestination)?)
        case flowSpecificDestinationAfterEmbededFlow

        var id: String {
            switch self {
            case .flowSpecificDestination:
                "flowSpecificDestination"
            case let .embededFlow(destination):
                "embededFlow-\(destination?.id ?? "")"
            case .flowSpecificDestinationAfterEmbededFlow:
                "flowSpecificDestinationAfterEmbededFlow"
            }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
```
**/

public protocol CoordinatorSceneFlowProvider {
    associatedtype RootView: View
    associatedtype DestinationViews: View
    associatedtype Destination: Hashable & Identifiable

    @ViewBuilder
    static func rootView(with instance: Self) -> RootView

    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews

    var onNavigateToDestination: (Destination) -> Void { get }
    var onPop: () -> Void { get }

    var onPresentSheet: ((Destination) -> Void)? { get }
    var onDismissSheet: (() -> Void)? { get }
    var onPresentFullscreenCover: ((Destination) -> Void)? { get }
    var onDismissFullscreenCover: (() -> Void)? { get }
    var onPopToDestination: ((Destination?) -> Void)? { get }
    var onShowError: ((Error) -> Void)? { get }
}

public extension CoordinatorSceneFlowProvider {
    func navigate(to destination: Destination) {
        onNavigateToDestination(destination)
    }

    func pop() {
        onPop()
    }

    func present(sheet: Destination) {
        onPresentSheet?(sheet)
    }

    func onSheetDismiss() {
        onDismissSheet?()
    }

    func present(fullscreenCover: Destination) {
        onPresentFullscreenCover?(fullscreenCover)
    }

    func onFullscreenCoverDismiss() {
        onDismissFullscreenCover?()
    }

    func pop(to destination: Destination?) {
        onPopToDestination?(destination)
    }

    func show(error: Error) {
        onShowError?(error)
    }
}

