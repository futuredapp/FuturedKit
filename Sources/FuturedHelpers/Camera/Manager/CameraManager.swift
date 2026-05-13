#if canImport(UIKit)

import AVFoundation
import Foundation
import Observation

/// `@Observable` MainActor wrapper that drives a ``CameraSession`` and surfaces
/// the state needed by SwiftUI views (preview session, mode, flash, recording timer, …).
///
/// Camera permission must be granted before calling ``configureAndStart()``;
/// use ``CameraPermission/requestCameraAccess()``.
@Observable
@MainActor
public final class CameraManager {

    // MARK: - Observable UI State

    public private(set) var isSessionRunning = false
    public var captureMode: CaptureMode {
        didSet {
            guard captureMode != oldValue else {
                return
            }
            cameraSession.setCaptureMode(captureMode)
        }
    }
    public var flashMode: FlashMode = .off
    public private(set) var position: CameraPosition = .back
    public private(set) var isRecording = false
    public private(set) var recordingDuration: TimeInterval = 0
    public private(set) var lastError: CameraError?

    /// The underlying `AVCaptureSession` for use with ``CameraPreview``.
    public var captureSession: AVCaptureSession { cameraSession.captureSession }

    // MARK: - Private

    private let cameraSession: any CameraSessionType
    private var timerTask: Task<Void, Never>?
    /// `true` between `startRecording()` being called and the delegate
    /// confirming the recording actually began. Prevents the user from
    /// starting twice and ensures `stopRecording()` works on an in-flight start.
    private var isStartingRecording = false

    public init(session: any CameraSessionType = CameraSession(), initialCaptureMode: CaptureMode = .photo) {
        self.cameraSession = session
        self.captureMode = initialCaptureMode
        session.delegate = self
    }

    // MARK: - Session Lifecycle

    /// Requests microphone access (for video) in the background, then configures and
    /// starts the underlying capture session. Camera permission must already be granted.
    public func configureAndStart() {
        Task {
            _ = await AVCaptureDevice.requestAccess(for: .audio)
        }
        cameraSession.configure(mode: captureMode, position: position)
    }

    public func stop() {
        cameraSession.stop()
    }

    // MARK: - Camera Switch

    public func switchCamera() {
        guard !isRecording else {
            return
        }
        cameraSession.switchCamera()
    }

    // MARK: - Flash

    /// Advances the flash mode (off → on → auto → off). If recording is active,
    /// the torch is updated to match.
    public func cycleFlash() {
        flashMode = flashMode.next
        if isRecording {
            cameraSession.setTorchMode(flashMode)
        }
    }

    // MARK: - Photo Capture

    public func takePhoto() async -> URL? {
        let url = await cameraSession.takePhoto(flashMode: flashMode)
        if url == nil {
            lastError = .noPhotoData
        }
        return url
    }

    // MARK: - Video Recording

    public func startRecording() {
        guard !isRecording, !isStartingRecording else {
            return
        }
        isStartingRecording = true
        cameraSession.startRecording(flashMode: flashMode)
    }

    public func stopRecording() async -> URL? {
        guard isRecording || isStartingRecording else {
            return nil
        }
        let url = await cameraSession.stopRecording()
        isStartingRecording = false
        isRecording = false
        stopRecordingTimer()
        return url
    }

    // MARK: - Timer

    private func startRecordingTimer() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.recordingDuration += 1
            }
        }
    }

    private func stopRecordingTimer() {
        timerTask?.cancel()
        timerTask = nil
        recordingDuration = 0
    }
}

// MARK: - CameraSessionDelegate

extension CameraManager: CameraSessionDelegate {
    public nonisolated func cameraSessionDidStart() {
        Task { @MainActor [weak self] in
            self?.isSessionRunning = true
        }
    }

    public nonisolated func cameraSessionDidStop() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            isSessionRunning = false
            isStartingRecording = false
            isRecording = false
            stopRecordingTimer()
        }
    }

    public nonisolated func cameraSession(didChangePosition position: CameraPosition) {
        Task { @MainActor [weak self] in
            self?.position = position
        }
    }

    public nonisolated func cameraSessionRecordingDidStart() {
        Task { @MainActor [weak self] in
            guard let self, isStartingRecording else {
                return
            }
            isStartingRecording = false
            isRecording = true
            recordingDuration = 0
            startRecordingTimer()
        }
    }

    public nonisolated func cameraSession(recordingDidFinish url: URL?) {
        // No-op: ``stopRecording()`` already returned the URL to the caller.
    }

    public nonisolated func cameraSession(didFail error: CameraError) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            lastError = error
            isSessionRunning = false
        }
    }
}

#endif
