#if canImport(UIKit)

import AVFoundation
import Foundation

/// Abstracts the camera session so ``CameraManager`` can be exercised without a
/// real ``AVCaptureSession``. Conforming types must be safe to call from any
/// actor; implementations are expected to confine mutable state internally.
public protocol CameraSessionType: AnyObject, Sendable {
    /// The underlying capture session used by ``CameraPreview``.
    var captureSession: AVCaptureSession { get }

    /// The receiver of session lifecycle and recording events.
    var delegate: CameraSessionDelegate? { get set }

    func configure(mode: CaptureMode, position: CameraPosition)
    func stop()
    func switchCamera()
    func setCaptureMode(_ mode: CaptureMode)
    func takePhoto(flashMode: FlashMode) async -> URL?
    func startRecording(flashMode: FlashMode)
    func stopRecording() async -> URL?
    func setTorchMode(_ flashMode: FlashMode)
}

#endif
