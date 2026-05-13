#if canImport(UIKit)

import AVFoundation
import AVKit
import SwiftUI

/// Drop-in camera UI driven by ``CameraManager``. Composed from reusable
/// subviews (``CameraTopBar``, ``CameraActionsRow``, ``CameraCaptureButton``)
/// so projects can build their own UI by picking and choosing pieces, or by
/// styling the default via ``CameraViewStyle``.
public struct DefaultCameraView: View {
    private let camera: CameraManager
    private let style: CameraViewStyle
    private let strings: CameraViewStrings
    private let onCapture: (URL) -> Void
    private let onCancel: () -> Void

    public init(
        camera: CameraManager,
        style: CameraViewStyle = .default,
        strings: CameraViewStrings = .default,
        onCapture: @escaping (URL) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.camera = camera
        self.style = style
        self.strings = strings
        self.onCapture = onCapture
        self.onCancel = onCancel
    }

    public var body: some View {
        cameraContent
            .background { style.backgroundColor.ignoresSafeArea() }
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

    private var cameraContent: some View {
        CameraPreview(session: camera.captureSession)
            .ignoresSafeArea()
            .overlay { overlay }
    }

    private var overlay: some View {
        VStack(spacing: 0) {
            CameraTopBar(
                flashMode: camera.flashMode,
                isRecording: camera.isRecording,
                recordingDuration: camera.recordingDuration,
                style: style,
                strings: strings,
                onFlashTap: camera.cycleFlash
            )
            .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 0) {
                CameraCaptureButton(
                    mode: camera.captureMode,
                    isRecording: camera.isRecording,
                    style: style,
                    action: handleCapture
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, style.captureButtonTopPadding)
                .padding(.bottom, style.captureButtonBottomPadding)

                CameraActionsRow(
                    captureMode: camera.captureMode,
                    isRecording: camera.isRecording,
                    style: style,
                    strings: strings,
                    onSelectMode: { camera.captureMode = $0 },
                    onSwitchCamera: camera.switchCamera,
                    onCancel: onCancel
                )
                .padding(.horizontal, style.horizontalPadding)
                .padding(.bottom, style.actionsBottomPadding)
            }
            .background {
                style.chromeBackgroundColor.ignoresSafeArea()
            }
        }
    }

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
