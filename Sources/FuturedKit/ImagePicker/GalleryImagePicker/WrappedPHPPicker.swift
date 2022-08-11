#if canImport(UIKit)

import PhotosUI
import SwiftUI

@available(iOS 14, *)
/// Wrapped `PHPickerViewController`. If you need gallery picker for iOS 13 you can use `WrappedUIImagePicker`.
public struct WrappedPHPicker: UIViewControllerRepresentable {
    private let configuration: PHPickerConfiguration
    private let didFinishPicking: ([PHPickerResult]) -> Void
    
    /// Creates a wrapped `PHPickerViewController` with the configuration and the handler
    /// for data processing.
    /// - Parameters:
    ///   - configuration: The configuration with which to initialize the view controller.
    ///   - didFinishPickingMediaWithInfo: The handler which process data obtained
    ///   by `imagePickerController(_:didFinishPickingMediaWithInfo:)` delegate method.
    ///   - setup: The closure for additional view controller setup.
    public init(
        configuration: PHPickerConfiguration,
        didFinishPicking: @escaping ([PHPickerResult]) -> Void
    ) {
        self.configuration = configuration
        self.didFinishPicking = didFinishPicking
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(didFinishPicking: handleSelection)
    }
    
    private func handleSelection(_ results: [PHPickerResult]) {
        didFinishPicking(results)
    }
    
    public final class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
        let didFinishPicking: ([PHPickerResult]) -> Void
        
        init(didFinishPicking: @escaping ([PHPickerResult]) -> Void) {
            self.didFinishPicking = didFinishPicking
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            didFinishPicking(results)
        }
    }
}

#endif
