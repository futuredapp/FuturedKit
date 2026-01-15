#if canImport(UIKit)

import BindingKit
import SwiftUI
import PhotosUI

/// A view that displays a Photos picker for choosing assets from the photo library.
///
/// ## Overview
///
/// Gallery image picker uses `WrappedPHPicker`. It supports single and multiple selection.
/// After selection is the view automatically dismissed.
public struct GalleryImagePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var selection: [UIImage]

    private let selectionLimit: Int

    /// Creates a picker that selects an images which count is specified by `selection` parameter.
    /// - Parameters:
    ///   - selection: The selected images.
    ///   - selectionLimit: The maximum number of selections the user can make.
    public init(selection: Binding<[UIImage]>, selectionLimit: Int = 0) {
        self._selection = selection
        self.selectionLimit = selectionLimit
    }

    /// Creates a picker that selects an image.
    /// - Parameters:
    ///   - selection: The selected images.
    ///   - selectionLimit: The maximum number of selections the user can make.
    public init(selection: Binding<UIImage?>) {
        self._selection = selection.map { image in
            [image].compactMap { $0 }
        } back: { images in
            images.first
        }
        self.selectionLimit = 1
    }

    public var body: some View {
        WrappedPHPicker(configuration: configuration, didFinishPicking: handlePickerResult)
            .ignoresSafeArea()
    }

    private var configuration: PHPickerConfiguration {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit
        return configuration
    }

    private func handlePickerResult(_ results: [PHPickerResult]) {
        dismiss()

        Task {
            var images: [UIImage] = []
            images.reserveCapacity(results.count)

            for result in results {
                let provider = result.itemProvider
                let image = try await provider.loadImage()
                images.append(image)
            }
            await MainActor.run {
                selection = images
            }
        }
    }
}

extension NSItemProvider {
    enum LoadImageError: Error {
        case castToImageFailed
    }

    func loadImage() async throws -> UIImage {
        guard canLoadObject(ofClass: UIImage.self) else {
            throw NSError()
        }

        return try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: UIImage.self) { image, error in
                if let image = image as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: error ?? LoadImageError.castToImageFailed)
                }
            }
        }
    }
}

#endif
