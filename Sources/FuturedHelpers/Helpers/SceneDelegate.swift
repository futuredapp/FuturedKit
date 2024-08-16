//
//  SceneDelegate.swift
//
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftUI

#if !os(macOS)
protocol AppSceneDelegate: AnyObject, UIWindowSceneDelegate, ObservableObject {
    var delegate: SceneDelegate? { get set }
}

protocol SceneDelegate: AnyObject {
    func sceneDidEnterBackground(_ scene: UIScene)
    func sceneWillEnterForeground(_ scene: UIScene)
}

private struct SceneDelegateWrapperViewModifier<ApSceneDelegate: AppSceneDelegate>: ViewModifier {
    @EnvironmentObject private var sceneDelegate: ApSceneDelegate

    let delegate: SceneDelegate?

    func body(content: Content) -> some View {
        content
            .onAppear {
                sceneDelegate.delegate = delegate
            }
    }
}

extension View {
    /// Sets the SceneDelegate for the application.
    /// - Parameter appSceneDelegateClass: The call which conforms to the UIWindowSceneDelegate.
    /// - Parameter sceneDelegate: The SceneDelegate to set.
    /// - Description:
    /// In the main app root view call this modifier and pass the SceneDelegate. You need to specify the AppSceneDelegate which conforms to the UIWindowSceneDelegate.
    /// This is necessary because the SceneDelegate is accessible in SwiftUI only via EnviromentObject.
    func set<T: AppSceneDelegate>(appSceneDelegateClass: T.Type, sceneDelegate: SceneDelegate) -> some View {
        modifier(SceneDelegateWrapperViewModifier<T>(delegate: sceneDelegate))
    }
}
#endif
