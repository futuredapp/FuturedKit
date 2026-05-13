#if canImport(UIKit)

import AVFoundation
import Foundation
import os

/// Owns a single in-flight photo capture: builds settings, retains the AV
/// delegate object, writes the result to a temp file, and resumes the
/// awaiting continuation exactly once.
///
/// All public methods are invoked on the session's serial queue.
final class PhotoCaptureCoordinator: @unchecked Sendable {
    private var delegate: PhotoCaptureDelegate?

    /// Captures a photo via the given `AVCapturePhotoOutput`. Returns the file
    /// URL of the written JPEG, or `nil` if capture failed or was cancelled.
    func capture(
        output: AVCapturePhotoOutput,
        device: AVCaptureDevice?,
        flashMode: FlashMode
    ) async -> URL? {
        await withCheckedContinuation { continuation in
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            if let device, device.hasFlash {
                settings.flashMode = flashMode.avFlashMode
            }
            let delegate = PhotoCaptureDelegate { [weak self] url in
                self?.delegate = nil
                continuation.resume(returning: url)
            }
            self.delegate = delegate
            output.capturePhoto(with: settings, delegate: delegate)
        }
    }

    /// Cancels an in-flight capture (if any) by resuming its continuation with
    /// `nil`. Safe to call when nothing is in flight.
    func cancel() {
        let pending = delegate
        delegate = nil
        pending?.cancel()
    }
}

/// AVFoundation photo delegate. Bridges the framework's callback-based API to
/// Swift concurrency via a single-shot completion that is guarded by an
/// `OSAllocatedUnfairLock` against concurrent resume / cancel.
private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let state = OSAllocatedUnfairLock<(@Sendable (URL?) -> Void)?>(initialState: nil)

    init(completion: @escaping @Sendable (URL?) -> Void) {
        super.init()
        state.withLock { $0 = completion }
    }

    func cancel() {
        consumeHandler()?(nil)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let handler = consumeHandler()

        guard error == nil, let data = photo.fileDataRepresentation() else {
            handler?(nil)
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        do {
            try data.write(to: url)
            handler?(url)
        } catch {
            handler?(nil)
        }
    }

    private func consumeHandler() -> (@Sendable (URL?) -> Void)? {
        state.withLock { value in
            let current = value
            value = nil
            return current
        }
    }
}

#endif
