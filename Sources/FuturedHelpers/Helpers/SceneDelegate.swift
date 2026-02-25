//
//  SceneDelegate.swift
//
//
//  Created by Simon Sestak on 31/07/2024.
//

import SwiftUI

#if !os(macOS)
/// Protocol for the app's scene delegate that can be observed via SwiftUI's environment.
///
/// Conform your `UIWindowSceneDelegate` to this protocol and annotate it with `@Observable`.
/// Then inject it into the SwiftUI environment from your root view using `.environment()`.
///
/// ```swift
/// // 1. Declare the delegate
/// @Observable
/// final class MySceneDelegate: NSObject, AppSceneDelegate {
///     var delegate: SceneDelegate?
///     // ... UIWindowSceneDelegate implementation
/// }
///
/// // 2. Inject at the root
/// @main
/// struct MyApp: App {
///     @State private var sceneDelegate = MySceneDelegate()
///
///     var body: some Scene {
///         WindowGroup {
///             RootView()
///                 .environment(sceneDelegate)
///         }
///     }
/// }
///
/// // 3. Use in a view
/// struct RootView: View {
///     var body: some View {
///         ContentView()
///             .set(appSceneDelegateClass: MySceneDelegate.self, sceneDelegate: mySceneDelegate)
///     }
/// }
/// ```
///
/// - Important: Forgetting to inject the delegate via `.environment()` will cause a runtime crash.
/// Unlike `@EnvironmentObject`, the compiler cannot warn you about a missing injection.
public protocol AppSceneDelegate: AnyObject, UIWindowSceneDelegate, Observable {
    var delegate: SceneDelegate? { get set }
}

public protocol SceneDelegate: AnyObject {
    func sceneDidEnterBackground(_ scene: UIScene)
    func sceneWillEnterForeground(_ scene: UIScene)
}

private struct SceneDelegateWrapperViewModifier<Delegate: AppSceneDelegate>: ViewModifier {
    @Environment(Delegate.self) private var appSceneDelegate: Delegate?

    let sceneDelegate: SceneDelegate?

    func body(content: Content) -> some View {
        content
            .onAppear {
                appSceneDelegate?.delegate = sceneDelegate
            }
    }
}

extension View {
    /// Sets the SceneDelegate for the application.
    /// - Parameter appSceneDelegateClass: The class which conforms to the UIWindowSceneDelegate.
    /// - Parameter sceneDelegate: The SceneDelegate to set.
    /// - Description:
    /// In the main app root view call this modifier and pass the SceneDelegate. You need to specify the AppSceneDelegate which conforms to the UIWindowSceneDelegate.
    /// The AppSceneDelegate must be injected into the environment using `.environment()` modifier.
    public func set<T: AppSceneDelegate>(appSceneDelegateClass: T.Type, sceneDelegate: SceneDelegate) -> some View {
        modifier(SceneDelegateWrapperViewModifier<T>(sceneDelegate: sceneDelegate))
    }
}
#endif
