//
//  CoordinatorSceneFlowProvider.swift
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftUI
import FuturedArchitecture

/**
 A protocol providing an interface for reusable scene flow providers. *Reusable scene flow provider* is part of a scene flow, which can be used as a part of more *Flow Coordinators*. The shared section of the flow is taken out of the *Flow Coordinator* and placed into a class conforming to `CoordinatorSceneFlowProvider`.

 Protocol defines necessary (`navigateTo`, `pop`) and optional navigation functions.
 Optional functions cater to specific navigational use cases like presenting/dismissing modal screen, and popping to destinations.

 - Warning: The `@EnumIndetable` macro won't function with this scene provider as you need to define a destination with an associated value, which isn't primitive.

 # Notes: #
 1. Declare the scene flow provider as a lazy var property in the coordinator.
 2. Coordinator destinations should have an enum that encapsulates flow provider destinations.
    - `case embededFlow(destination: TemplateSceneFlowProvider.Destination)`

 # Example #
 The scene provider is defined in the coordinator as follows:
 ```
 private lazy var templateSceneFlowProvider: TemplateSceneFlowProvider = {
    TemplateSceneFlowProvider(
        container: container,
        navigateTo: { [weak self] destination in
            if destination == .end {
                self?.navigate(to: .flowSpecificDestinationAfterEmbededFlow)
            } else {
                self?.navigate(to: .embeded(destination: destination))
            }
        }, pop: { [weak self] in
            self?.pop()
        }
    )
 }()
 ```
 Then scenes can be provided in flow coordinator like:
 ```
 func scene(for destination: Destination) -> some View {
    switch destination {
    case let .embededFlow(destination):
        templateSceneFlowProvider.scene(for: destination)
    case .flowSpecificDestinationAfterEmbededFlow:
        SomeComponent(model: ...
    }
 }
 ```
 */
public protocol CoordinatorSceneFlowProvider {
    associatedtype Destination: Hashable & Identifiable
    associatedtype DestinationViews: View

    @ViewBuilder
    func scene(for destination: Destination) -> DestinationViews

    var navigateTo: (Destination) -> Void { get }
    var pop: () -> Void { get }

    var present: ((Destination, ModalCoverModel<Destination>.Style) -> Void)? { get }
    var dismissModal: (() -> Void)? { get }
    var onModalDismiss: (() -> Void)? { get }
    var popTo: ((Destination?) -> Void)? { get }
}
