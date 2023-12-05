//  ___FILEHEADER___

import UIKit

protocol ___VARIABLE_appIdentifier___AppDelegateProtocol: AnyObject {
    func applicationDidFinishLaunching(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}

class ___VARIABLE_appIdentifier___AppDelegate: UIResponder, UIApplicationDelegate, ObservableObject {
    weak var delegate: ___VARIABLE_appIdentifier___AppDelegateProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        delegate?.applicationDidFinishLaunching(with: launchOptions)
        return true
    }
}
