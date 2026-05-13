#if canImport(UIKit)

import AVFoundation
import AVKit
import SwiftUI

/// Caller-supplied strings shown in ``DefaultCameraView``. The framework does not
/// localize on the consumer's behalf — pass already-localized values.
public struct CameraViewStrings: Sendable {
    public let cancel: String
    public let photoMode: String
    public let videoMode: String
    public let flashAuto: String

    public init(
        cancel: String = "Cancel",
        photoMode: String = "Photo",
        videoMode: String = "Video",
        flashAuto: String = "Auto"
    ) {
        self.cancel = cancel
        self.photoMode = photoMode
        self.videoMode = videoMode
        self.flashAuto = flashAuto
    }

    public static let `default` = CameraViewStrings()

    func label(for mode: CaptureMode) -> String {
        switch mode {
        case .photo: photoMode
        case .video: videoMode
        }
    }
}

/// Drop-in camera UI driven by ``CameraManager``. Projects that want custom UI
/// can build their own view on top of ``CameraPreview`` and ``CameraManager``.
public struct DefaultCameraView: View {
    @Bindable private var camera: CameraManager
    private let strings: CameraViewStrings
    private let onCapture: (URL) -> Void
    private let onCancel: () -> Void

    public init(
        camera: CameraManager,
        strings: CameraViewStrings = .default,
        onCapture: @escaping (URL) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.camera = camera
        self.strings = strings
        self.onCapture = onCapture
        self.onCancel = onCancel
    }

    public var body: some View {
        cameraContent
            .background { Color.black.ignoresSafeArea() }
            .modifier(CameraCaptureEventModifier(handler: handleCapture))
            .statusBarHidden()
            .persistentSystemOverlays(.hidden)
            .task {
                camera.configureAndStart()
            }
            .onDisappear {
                camera.stop()
            }
    }

    // MARK: - Layout

    private var cameraContent: some View {
        CameraPreview(session: camera.captureSession)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 0) {
                    topBar
                        .frame(maxHeight: .infinity, alignment: .top)
                    VStack(spacing: 0) {
                        captureButton
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 16)
                            .padding(.bottom, 32)
                        actionsRow
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                    .background {
                        Color.black.opacity(0.4).ignoresSafeArea()
                    }
                }
            }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 0) {
            flashButton
            Spacer()
            if camera.isRecording {
                recordingIndicator
                Spacer()
            } else if camera.flashMode == .auto {
                flashBadge
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var flashButton: some View {
        Button {
            camera.cycleFlash()
        } label: {
            Image(systemName: camera.flashMode.symbolName)
                .font(.system(size: 20))
                .foregroundStyle(camera.flashMode == .off ? .white : .yellow)
                .frame(width: 48, height: 48)
        }
    }

    private var flashBadge: some View {
        Text(strings.flashAuto)
            .font(.caption2.bold())
            .foregroundStyle(.black)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.yellow, in: Capsule())
    }

    private var recordingIndicator: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Text(formattedDuration)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.6), in: Capsule())
    }

    private var formattedDuration: String {
        let minutes = Int(camera.recordingDuration) / 60
        let seconds = Int(camera.recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Actions Row

    private var actionsRow: some View {
        HStack(spacing: 24) {
            cancelButton
            Spacer()
            modePicker
            Spacer()
            switchCameraButton
        }
    }

    private var modePicker: some View {
        HStack(spacing: 16) {
            ForEach(CaptureMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        camera.captureMode = mode
                    }
                } label: {
                    Text(strings.label(for: mode))
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(camera.captureMode == mode ? .yellow : .white.opacity(0.6))
                }
            }
        }
        .disabled(camera.isRecording)
    }

    private var cancelButton: some View {
        Button {
            onCancel()
        } label: {
            Text(strings.cancel)
                .foregroundStyle(.white)
                .frame(width: 72)
        }
    }

    private var captureButton: some View {
        Button {
            handleCapture()
        } label: {
            ZStack {
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .frame(width: 72, height: 72)
                captureButtonInner
            }
        }
    }

    @ViewBuilder
    private var captureButtonInner: some View {
        switch camera.captureMode {
        case .photo:
            Circle()
                .fill(.white)
                .frame(width: 64, height: 64)
        case .video:
            if camera.isRecording {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.red)
                    .frame(width: 32, height: 32)
            } else {
                Circle()
                    .fill(.red)
                    .frame(width: 64, height: 64)
            }
        }
    }

    private var switchCameraButton: some View {
        Button {
            camera.switchCamera()
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.15), in: Circle())
        }
        .frame(width: 72)
    }

    // MARK: - Capture Action

    private func handleCapture() {
        Task {
            switch camera.captureMode {
            case .photo:
                guard let url = await camera.takePhoto() else {
                    return
                }
                onCapture(url)
            case .video:
                if camera.isRecording {
                    guard let url = await camera.stopRecording() else {
                        return
                    }
                    onCapture(url)
                } else {
                    camera.startRecording()
                }
            }
        }
    }
}

// MARK: - Hardware Shutter

/// Wires the iOS 18+ `onCameraCaptureEvent` modifier without leaking the
/// availability check into call sites.
private struct CameraCaptureEventModifier: ViewModifier {
    let handler: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onCameraCaptureEvent { event in
                if event.phase == .ended {
                    handler()
                }
            }
        } else {
            content
        }
    }
}

#endif
