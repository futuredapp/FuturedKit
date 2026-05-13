#if canImport(UIKit)

import AVFoundation
import Foundation

/// Stateless helpers that build AV inputs and reconfigure outputs. All methods
/// must be invoked on the session's serial queue while the caller wraps the
/// AVCaptureSession in `beginConfiguration` / `commitConfiguration` where
/// noted.
struct CameraConfigurator {
    /// Resolves the wide-angle camera (or any default video device) for the
    /// given position and wraps it in an `AVCaptureDeviceInput`.
    static func makeVideoInput(for position: CameraPosition) -> AVCaptureDeviceInput? {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position.avPosition)
            ?? AVCaptureDevice.default(for: .video)
        guard let device else {
            return nil
        }
        return try? AVCaptureDeviceInput(device: device)
    }

    /// Resolves the default audio input for video recording.
    static func makeAudioInput() -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(for: .audio) else {
            return nil
        }
        return try? AVCaptureDeviceInput(device: device)
    }

    /// Forces captured photos and videos to be non-mirrored, even with the
    /// front camera. The preview layer continues to mirror automatically.
    /// Caller must invoke after `commitConfiguration`.
    static func disableMirroring(on photoOutput: AVCapturePhotoOutput, movieOutput: AVCaptureMovieFileOutput) {
        if let connection = photoOutput.connection(with: .video),
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }
        if let connection = movieOutput.connection(with: .video),
           connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }
    }

    /// Adds the movie output if it is not already attached. Caller must wrap
    /// in `begin/commitConfiguration`.
    static func addMovieOutputIfNeeded(
        _ movieOutput: AVCaptureMovieFileOutput,
        on session: AVCaptureSession
    ) {
        guard !session.outputs.contains(where: { $0 is AVCaptureMovieFileOutput }) else {
            return
        }
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            session.sessionPreset = .high
        }
    }

    /// Removes the movie output if attached. Caller must wrap in
    /// `begin/commitConfiguration`.
    static func removeMovieOutputIfNeeded(
        _ movieOutput: AVCaptureMovieFileOutput,
        on session: AVCaptureSession
    ) {
        guard session.outputs.contains(where: { $0 is AVCaptureMovieFileOutput }) else {
            return
        }
        session.removeOutput(movieOutput)
        session.sessionPreset = .photo
    }
}

#endif
