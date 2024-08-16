//
//  CoordinatorSceneFlowProvider.swift
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftUI
import FuturedArchitecture

/**
 A typealias representing navigable destinations in a reusable scene flow.

 # Notes: #
 1. If the scenes defined in the provider can continue with other scenes, define an end destination.
    - This end destination should trigger a scene display outside of the scene provider.
 2. Other destinations will be used to display scenes defined within the scene provider.

 # Example #
 ```
 protocol TemplateFlowDestination: CoordinatorSceneFlowDestination {
    static var destination: Self { get }
    static var end: Self { get }
 }
 ```
 */
public typealias CoordinatorSceneFlowDestination = Hashable & Identifiable & Equatable


/**
 A protocol providing an interface for reusable scene flow providers.
 Protocol defines necessary (`navigateTo`, `pop`) and optional navigation functions.
 Optional functions cater to specific navigational use cases like presenting/dismissing modal screen, and popping to destinations.

 - Warning: The `@EnumIndetable` macro won't function with this scene provider as you need to define a destination with an associated value, which isn't primitive.

 # Notes: #
 1. Declare the scene flow provider as a lazy var property in the coordinator.
 2. Coordinator destinations should have an enum that encapsulates flow provider destinations.
 - `case embededFlow(destination: (any TemplateFlowDestination)?)`
 3. To display the first scene of a scene provider, navigate to the embedded flow with nil.
 - `instance?.navigate(to: .embededFlow(destination: nil))`

 # Example #
 The scene provider is defined in the coordinator as follows:
 ```
 private lazy var templateSceneProvider: TemplateSceneFlowProvider = {
    TemplateSceneFlowProvider(
        container: container,
        navigateTo: { [weak self] destination in
            if destination == .end {
                self?.navigate(to: .flowSpecificDestinationAfterEmbededFlow)
            } else {
                self?.navigate(to: destination)
            }
        }, pop: { [weak self] in
            self?.pop()
        }
    )
 }()
 ```
 To create a scene from the SceneFlowProvider:
 ```
 @ViewBuilder
 private func embededFlowScenes(destination: (any TemplateFlowDestination)?) -> some View {
    if let destination = destination as? TemplateSceneFlowProvider.Destination {
        templateSceneProvider.scene(for: destination)
    } else {
        TemplateSceneFlowProvider.rootView(with: templateSceneProvider)
    }
 }
 ```
 */
public protocol CoordinatorSceneFlowProvider {
    associatedtype Destination: Hashable & Identifiable
    associatedtype RootView: View
    associatedtype DestinationViews: View

    @ViewBuilder
    static func rootView(with instance: Self) -> RootView

    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews

    var navigateTo: (Destination) -> Void { get }
    var pop: () -> Void { get }

    var present: ((Destination, ModalCoverModel<Destination>.Style) -> Void)? { get }
    var dismissModal: (() -> Void)? { get }
    var onModalDismiss: (() -> Void)? { get }
    var popTo: ((Destination?) -> Void)? { get }
}
