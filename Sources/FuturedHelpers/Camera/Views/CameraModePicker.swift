#if canImport(UIKit)

import SwiftUI

/// Photo / Video segmented picker. Disabled while recording.
public struct CameraModePicker: View {
    private let selection: CaptureMode
    private let isRecording: Bool
    private let style: CameraViewStyle
    private let strings: CameraViewStrings
    private let onSelect: (CaptureMode) -> Void

    public init(
        selection: CaptureMode,
        isRecording: Bool,
        style: CameraViewStyle,
        strings: CameraViewStrings,
        onSelect: @escaping (CaptureMode) -> Void
    ) {
        self.selection = selection
        self.isRecording = isRecording
        self.style = style
        self.strings = strings
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: style.modeSpacing) {
            ForEach(CaptureMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onSelect(mode)
                    }
                } label: {
                    Text(strings.label(for: mode))
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(selection == mode ? style.accentColor : style.secondaryTextColor)
                }
            }
        }
        .disabled(isRecording)
    }
}

#endif
