#if canImport(UIKit)

import AVFoundation
import Foundation
import os

/// Owns the AVFoundation capture session and orchestrates the per-feature
/// coordinators (``PhotoCaptureCoordinator``, ``VideoRecordingCoordinator``,
/// ``TorchController``, ``CameraConfigurator``).
///
/// Thread-safety contract (`@unchecked Sendable`):
/// - Session-queue-only (mutable): `videoInput`, `audioInput`, `currentCaptureMode`,
///   `currentPosition`, `photoCaptureCoordinator`'s state, `videoRecordingCoordinator`'s state
/// - Immutable (`let`): `captureSession`, `sessionQueue`, `photoOutput`, `movieOutput`,
///   `photoCaptureCoordinator`, `videoRecordingCoordinator`
/// - Synchronized via `delegateLock`: `delegate`
public nonisolated final class CameraSession: CameraSessionType, @unchecked Sendable {

    /// The underlying capture session. Exposed for ``CameraPreview``.
    public let captureSession = AVCaptureSession()

    private let delegateLock = OSAllocatedUnfairLock<CameraSessionDelegate?>(initialState: nil)
    public var delegate: CameraSessionDelegate? {
        get { delegateLock.withLock { $0 } }
        set { delegateLock.withLock { $0 = newValue } }
    }

    private let sessionQueue = DispatchQueue(label: "app.futured.futuredkit.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let photoCaptureCoordinator = PhotoCaptureCoordinator()
    private let videoRecordingCoordinator = VideoRecordingCoordinator()

    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private var currentPosition: CameraPosition = .back
    private var currentCaptureMode: CaptureMode = .photo

    public init() {}

    // MARK: - Session Lifecycle

    public func configure(mode: CaptureMode = .photo, position: CameraPosition = .back) {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            currentCaptureMode = mode
            currentPosition = position
            configureSession()
        }
    }

    public func stop() {
        sessionQueue.async { [weak self] in
            guard let self, captureSession.isRunning else {
                return
            }
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }
            TorchController.apply(.off, to: videoInput?.device)
            captureSession.stopRunning()
            photoCaptureCoordinator.cancel()
            audioInput = nil
            notifyDelegate { $0.cameraSessionDidStop() }
        }
    }

    private func configureSession() {
        guard let input = CameraConfigurator.makeVideoInput(for: currentPosition) else {
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
            CameraConfigurator.addMovieOutputIfNeeded(movieOutput, on: captureSession)
        }

        captureSession.commitConfiguration()
        CameraConfigurator.disableMirroring(on: photoOutput, movieOutput: movieOutput)
        captureSession.startRunning()

        notifyDelegate { $0.cameraSessionDidStart() }
    }

    // MARK: - Camera Switch

    public func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            let newPosition = currentPosition.toggled
            guard let newInput = CameraConfigurator.makeVideoInput(for: newPosition) else {
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
            CameraConfigurator.disableMirroring(on: photoOutput, movieOutput: movieOutput)

            notifyDelegate { [newPosition] in $0.cameraSession(didChangePosition: newPosition) }
        }
    }

    // MARK: - Capture Mode

    public func setCaptureMode(_ mode: CaptureMode) {
        sessionQueue.async { [weak self] in
            guard let self, currentCaptureMode != mode else {
                return
            }
            currentCaptureMode = mode
            captureSession.beginConfiguration()
            switch mode {
            case .photo:
                CameraConfigurator.removeMovieOutputIfNeeded(movieOutput, on: captureSession)
            case .video:
                CameraConfigurator.addMovieOutputIfNeeded(movieOutput, on: captureSession)
            }
            captureSession.commitConfiguration()
            CameraConfigurator.disableMirroring(on: photoOutput, movieOutput: movieOutput)
        }
    }

    // MARK: - Photo Capture

    public func takePhoto(flashMode: FlashMode) async -> URL? {
        await withCheckedContinuation { (continuation: CheckedContinuation<URL?, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }

                if captureSession.outputs.contains(where: { $0 is AVCaptureMovieFileOutput }) {
                    captureSession.beginConfiguration()
                    CameraConfigurator.removeMovieOutputIfNeeded(movieOutput, on: captureSession)
                    captureSession.commitConfiguration()
                    CameraConfigurator.disableMirroring(on: photoOutput, movieOutput: movieOutput)
                }

                Task { [weak self] in
                    guard let self else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let url = await photoCaptureCoordinator.capture(
                        output: photoOutput,
                        device: videoInput?.device,
                        flashMode: flashMode
                    )
                    continuation.resume(returning: url)
                }
            }
        }
    }

    // MARK: - Video Recording

    public func startRecording(flashMode: FlashMode) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            CameraConfigurator.addMovieOutputIfNeeded(movieOutput, on: captureSession)
            CameraConfigurator.disableMirroring(on: photoOutput, movieOutput: movieOutput)
            addAudioInputIfNeeded()
            TorchController.apply(flashMode, to: videoInput?.device)

            videoRecordingCoordinator.start(on: movieOutput) { [weak self] in
                self?.notifyDelegate { $0.cameraSessionRecordingDidStart() }
            }
        }
    }

    public func stopRecording() async -> URL? {
        let url: URL? = await withCheckedContinuation { (continuation: CheckedContinuation<URL?, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }
                Task { [weak self] in
                    guard let self else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let result = await videoRecordingCoordinator.stop(on: movieOutput)
                    TorchController.apply(.off, to: videoInput?.device)
                    continuation.resume(returning: result)
                }
            }
        }

        sessionQueue.async { [weak self] in
            self?.removeAudioInput()
        }

        notifyDelegate { [url] in $0.cameraSession(recordingDidFinish: url) }
        return url
    }

    // MARK: - Torch

    public func setTorchMode(_ flashMode: FlashMode) {
        sessionQueue.async { [weak self] in
            TorchController.apply(flashMode, to: self?.videoInput?.device)
        }
    }

    // MARK: - Delegate Notification

    private func notifyDelegate(_ call: (CameraSessionDelegate) -> Void) {
        guard let delegate else {
            return
        }
        call(delegate)
    }
}

// MARK: - Audio Input

extension CameraSession {
    private func addAudioInputIfNeeded() {
        guard audioInput == nil else {
            return
        }
        guard let input = CameraConfigurator.makeAudioInput() else {
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
}

#endif
