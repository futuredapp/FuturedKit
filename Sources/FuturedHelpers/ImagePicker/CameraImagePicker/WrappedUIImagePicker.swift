#if canImport(UIKit)

import SwiftUI

/// Wrapped `UIImagePickerController`.
///
/// ## Overview
///
/// It allows to process data obtained by `imagePickerController(_:didFinishPickingMediaWithInfo:)` delegate method.
/// An additional view controller setup can by provided by optional `setup` parameter.
public struct WrappedUIImagePicker: UIViewControllerRepresentable {
    private let didFinishPickingMediaWithInfo: ([UIImagePickerController.InfoKey: Any]) -> Void
    private let setup: ((UIImagePickerController) -> Void)?

    /// Creates a wrapped `UIImagePickerController` with the handler for data processing and additional
    /// view controller setup.
    /// - Parameters:
    ///   - didFinishPickingMediaWithInfo: The handler which process data obtained
    ///   by `imagePickerController(_:didFinishPickingMediaWithInfo:)` delegate method.
    ///   - setup: The closure for additional view controller setup.
    public init(
        didFinishPickingMediaWithInfo: @escaping ([UIImagePickerController.InfoKey: Any]) -> Void,
        setup: ((UIImagePickerController) -> Void)? = nil
    ) {
        self.didFinishPickingMediaWithInfo = didFinishPickingMediaWithInfo
        self.setup = setup
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        setup?(uiViewController)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(didFinishPicking: didFinishPickingMediaWithInfo)
    }

    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var didFinishPicking: ([UIImagePickerController.InfoKey: Any]) -> Void

        init(didFinishPicking: @escaping ([UIImagePickerController.InfoKey: Any]) -> Void) {
            self.didFinishPicking = didFinishPicking
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            didFinishPicking(info)
        }
    }
}

#endif
