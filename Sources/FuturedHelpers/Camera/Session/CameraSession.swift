#if canImport(UIKit)

import AVFoundation
import Foundation
import os

/// Owns all AVFoundation objects for a camera capture session and confines mutable
/// state to a private serial queue.
///
/// Thread-safety contract (`@unchecked Sendable`):
/// - Session-queue-only (mutable): `videoInput`, `audioInput`, `photoDelegate`, `currentCaptureMode`, `currentPosition`
/// - Immutable (`let`): `captureSession`, `sessionQueue`, `photoOutput`, `movieOutput`, `videoDelegate`
/// - Set-once-before-use: `delegate`
public nonisolated final class CameraSession: @unchecked Sendable {

    /// The underlying capture session. Exposed for ``CameraPreview``.
    public let captureSession = AVCaptureSession()

    /// Set once before calling ``configure(mode:position:)``. Held weakly.
    public weak var delegate: CameraSessionDelegate?

    private let sessionQueue = DispatchQueue(label: "app.futured.futuredkit.camera.session")
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoDelegate = VideoCaptureDelegate()

    /// Session-queue-confined. All reads/writes occur inside `sessionQueue.async` blocks.
    private var photoDelegate: PhotoCaptureDelegate?
    private var currentPosition: CameraPosition = .back
    private var currentCaptureMode: CaptureMode = .photo

    public init() {}

    // MARK: - Session Lifecycle

    /// Configures the underlying `AVCaptureSession` with the given mode and position,
    /// then starts running. Callbacks are delivered via ``CameraSessionDelegate``.
    public func configure(mode: CaptureMode = .photo, position: CameraPosition = .back) {
        sessionQueue.async { [weak self] in
            self?.currentCaptureMode = mode
            self?.currentPosition = position
            self?.configureSession()
        }
    }

    /// Stops the session, ending any in-flight recording and turning the torch off.
    public func stop() {
        sessionQueue.async { [weak self] in
            guard let self, captureSession.isRunning else {
                return
            }
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
            applyTorchMode(.off)
            captureSession.stopRunning()
            if let delegate = photoDelegate {
                delegate.cancel()
                photoDelegate = nil
            }
            audioInput = nil
            notifyDelegate { $0.cameraSessionDidStop() }
        }
    }

    private func configureSession() {
        let position: AVCaptureDevice.Position = currentPosition == .back ? .back : .front
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
                ?? AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: videoDevice) else {
            notifyDelegate { $0.cameraSession(didFail: .configurationFailed) }
            return
        }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = currentCaptureMode == .photo ? .photo : .high

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            videoInput = input
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        if currentCaptureMode == .video {
            addMovieOutputIfNeeded()
        }

        captureSession.commitConfiguration()
        updateMirroring()
        captureSession.startRunning()

        notifyDelegate { $0.cameraSessionDidStart() }
    }

    // MARK: - Camera Switch

    /// Toggles between back and front camera.
    public func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self else {
                return
            }

            let newPosition = currentPosition.toggled
            let avPosition: AVCaptureDevice.Position = newPosition == .back ? .back : .front
            guard let newDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: avPosition
            ),
                  let newInput = try? AVCaptureDeviceInput(device: newDevice)
            else {
                return
            }

            captureSession.beginConfiguration()

            if let currentInput = videoInput {
                captureSession.removeInput(currentInput)
            }

            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
                videoInput = newInput
                currentPosition = newPosition
            }

            captureSession.commitConfiguration()
            updateMirroring()

            notifyDelegate { [newPosition] in $0.cameraSession(didChangePosition: newPosition) }
        }
    }

    // MARK: - Capture Mode

    /// Reconfigures outputs for the given capture mode.
    public func setCaptureMode(_ mode: CaptureMode) {
        sessionQueue.async { [weak self] in
            guard let self, currentCaptureMode != mode else {
                return
            }
            currentCaptureMode = mode
            captureSession.beginConfiguration()
            switch mode {
            case .photo:
                removeMovieOutputIfNeededLocked()
            case .video:
                addMovieOutputIfNeeded()
            }
            captureSession.commitConfiguration()
            updateMirroring()
        }
    }

    // MARK: - Photo Capture

    /// Captures a JPEG photo and writes it to a temporary file. Returns the file
    /// URL on success, or `nil` if capture failed or was cancelled.
    public func takePhoto(flashMode: FlashMode) async -> URL? {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                removeMovieOutputIfNeededLocked()

                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                if let device = videoInput?.device, device.hasFlash {
                    switch flashMode {
                    case .off:
                        settings.flashMode = .off
                    case .on:
                        settings.flashMode = .on
                    case .auto:
                        settings.flashMode = .auto
                    }
                }

                let delegate = PhotoCaptureDelegate { [weak self] url in
                    self?.sessionQueue.async { [weak self] in
                        self?.photoDelegate = nil
                    }
                    continuation.resume(returning: url)
                }
                self.photoDelegate = delegate
                photoOutput.capturePhoto(with: settings, delegate: delegate)
            }
        }
    }

    // MARK: - Video Recording

    /// Begins recording video to a temporary `.mov` file.
    public func startRecording(flashMode: FlashMode) {
        sessionQueue.async { [weak self] in
            guard let self else {
                return
            }

            addMovieOutputIfNeeded()
            updateMirroring()
            addAudioInputIfNeeded()
            applyTorchMode(flashMode)

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mov")
            movieOutput.startRecording(to: tempURL, recordingDelegate: videoDelegate)

            notifyDelegate { $0.cameraSessionRecordingDidStart() }
        }
    }

    /// Stops recording, returning the file URL on success or `nil` on failure.
    public func stopRecording() async -> URL? {
        let url: URL? = await withCheckedContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self, movieOutput.isRecording else {
                    continuation.resume(returning: nil)
                    return
                }
                videoDelegate.setContinuation(continuation)
                movieOutput.stopRecording()
                applyTorchMode(.off)
            }
        }

        sessionQueue.async { [weak self] in
            self?.removeAudioInput()
        }

        notifyDelegate { [url] in $0.cameraSession(recordingDidFinish: url) }
        return url
    }

    // MARK: - Torch

    /// Applies the torch state matching the given flash mode (used during recording).
    public func setTorchMode(_ flashMode: FlashMode) {
        sessionQueue.async { [weak self] in
            self?.applyTorchMode(flashMode)
        }
    }

    // MARK: - Delegate Notification

    private func notifyDelegate(_ call: @escaping @Sendable (CameraSessionDelegate) -> Void) {
        guard let delegate else {
            return
        }
        call(delegate)
    }
}

// MARK: - Session Helpers

extension CameraSession {
    private func addAudioInputIfNeeded() {
        guard audioInput == nil else {
            return
        }
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let input = try? AVCaptureDeviceInput(device: audioDevice) else {
            return
        }
        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
            audioInput = input
        }
        captureSession.commitConfiguration()
    }

    private func removeAudioInput() {
        guard let input = audioInput else {
            return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(input)
        captureSession.commitConfiguration()
        audioInput = nil
    }

    /// Forces captured photos and videos to be non-mirrored, even when shooting
    /// with the front camera. The preview layer continues to mirror for the user
    /// (handled automatically by `AVCaptureVideoPreviewLayer`).
    private func updateMirroring() {
        if let connection = photoOutput.connection(with: .video),
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }
        if let movieConn = movieOutput.connection(with: .video),
           movieConn.isVideoMirroringSupported {
            movieConn.automaticallyAdjustsVideoMirroring = false
            movieConn.isVideoMirrored = false
        }
    }

    private func addMovieOutputIfNeeded() {
        guard !captureSession.outputs.contains(where: { $0 is AVCaptureMovieFileOutput }) else {
            return
        }
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            captureSession.sessionPreset = .high
        }
    }

    /// Caller must wrap in begin/commitConfiguration.
    private func removeMovieOutputIfNeededLocked() {
        guard captureSession.outputs.contains(where: { $0 is AVCaptureMovieFileOutput }) else {
            return
        }
        captureSession.removeOutput(movieOutput)
        captureSession.sessionPreset = .photo
    }

    /// Must be called on `sessionQueue`.
    private func applyTorchMode(_ flashMode: FlashMode) {
        guard let device = videoInput?.device,
              device.hasTorch,
              (try? device.lockForConfiguration()) != nil else {
            return
        }
        switch flashMode {
        case .off:
            device.torchMode = .off
        case .on:
            device.torchMode = .on
        case .auto:
            device.torchMode = .auto
        }
        device.unlockForConfiguration()
    }
}

// MARK: - Photo Capture Delegate

private final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let state = OSAllocatedUnfairLock<(@Sendable (URL?) -> Void)?>(initialState: nil)

    init(completion: @escaping @Sendable (URL?) -> Void) {
        super.init()
        state.withLock { $0 = completion }
    }

    func cancel() {
        let handler = state.withLock { value in
            let current = value
            value = nil
            return current
        }
        handler?(nil)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let handler = state.withLock { value in
            let current = value
            value = nil
            return current
        }

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
}

// MARK: - Video Capture Delegate

/// Bridges AVFoundation's delegate-based recording API to Swift concurrency.
///
/// `setContinuation` is called from the session queue; `fileOutput(_:didFinishRecordingTo:...)`
/// is called by AVFoundation on an internal background thread. `OSAllocatedUnfairLock`
/// ensures the handoff is atomic and the continuation is resumed exactly once.
private final class VideoCaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {
    private let state = OSAllocatedUnfairLock<CheckedContinuation<URL?, Never>?>(initialState: nil)

    func setContinuation(_ continuation: CheckedContinuation<URL?, Never>) {
        state.withLock { $0 = continuation }
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        let continuation = state.withLock { value in
            let current = value
            value = nil
            return current
        }

        if error != nil {
            continuation?.resume(returning: nil)
        } else {
            continuation?.resume(returning: outputFileURL)
        }
    }
}

#endif
