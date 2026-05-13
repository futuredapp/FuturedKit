#if canImport(UIKit)

import SwiftUI

/// Bottom row of ``DefaultCameraView``: cancel button on the left, mode picker
/// in the middle, switch-camera button on the right.
public struct CameraActionsRow: View {
    private let captureMode: CaptureMode
    private let isRecording: Bool
    private let style: CameraViewStyle
    private let strings: CameraViewStrings
    private let onSelectMode: (CaptureMode) -> Void
    private let onSwitchCamera: () -> Void
    private let onCancel: () -> Void

    public init(
        captureMode: CaptureMode,
        isRecording: Bool,
        style: CameraViewStyle,
        strings: CameraViewStrings,
        onSelectMode: @escaping (CaptureMode) -> Void,
        onSwitchCamera: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.captureMode = captureMode
        self.isRecording = isRecording
        self.style = style
        self.strings = strings
        self.onSelectMode = onSelectMode
        self.onSwitchCamera = onSwitchCamera
        self.onCancel = onCancel
    }

    public var body: some View {
        HStack(spacing: style.actionSpacing) {
            CameraCancelButton(label: strings.cancel, style: style, action: onCancel)
            Spacer()
            CameraModePicker(
                selection: captureMode,
                isRecording: isRecording,
                style: style,
                strings: strings,
                onSelect: onSelectMode
            )
            Spacer()
            CameraSwitchButton(style: style, action: onSwitchCamera)
        }
    }
}

private struct CameraCancelButton: View {
    let label: String
    let style: CameraViewStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .foregroundStyle(style.primaryTextColor)
                .frame(width: style.sideButtonWidth)
        }
    }
}

private struct CameraSwitchButton: View {
    let style: CameraViewStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: style.iconFontSize))
                .foregroundStyle(style.primaryTextColor)
                .frame(width: style.iconButtonSize, height: style.iconButtonSize)
                .background(style.iconButtonBackground, in: Circle())
        }
        .frame(width: style.sideButtonWidth)
    }
}

#endif
