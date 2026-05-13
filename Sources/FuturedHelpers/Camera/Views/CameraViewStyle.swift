#if canImport(UIKit)

import SwiftUI

/// Style tokens used by ``DefaultCameraView`` and its subcomponents. Projects
/// that want a different look without rebuilding the camera UI can pass a
/// customized ``CameraViewStyle`` (or use ``CameraViewStyle/default``) and
/// optionally pair it with a custom ``CameraViewStrings``.
public struct CameraViewStyle: Sendable {
    public var backgroundColor: Color
    public var chromeBackgroundColor: Color
    public var accentColor: Color
    public var recordingColor: Color
    public var primaryTextColor: Color
    public var secondaryTextColor: Color
    public var iconButtonBackground: Color
    public var iconButtonSize: CGFloat
    public var captureButtonOuterSize: CGFloat
    public var captureButtonInnerSize: CGFloat
    public var captureButtonStopSize: CGFloat
    public var captureButtonStrokeWidth: CGFloat
    public var iconFontSize: CGFloat
    public var sideButtonWidth: CGFloat
    public var horizontalPadding: CGFloat
    public var topPadding: CGFloat
    public var captureButtonTopPadding: CGFloat
    public var captureButtonBottomPadding: CGFloat
    public var actionsBottomPadding: CGFloat
    public var modeSpacing: CGFloat
    public var actionSpacing: CGFloat

    public init(
        backgroundColor: Color = .black,
        chromeBackgroundColor: Color = .black.opacity(0.4),
        accentColor: Color = .yellow,
        recordingColor: Color = .red,
        primaryTextColor: Color = .white,
        secondaryTextColor: Color = .white.opacity(0.6),
        iconButtonBackground: Color = .white.opacity(0.15),
        iconButtonSize: CGFloat = 48,
        captureButtonOuterSize: CGFloat = 72,
        captureButtonInnerSize: CGFloat = 64,
        captureButtonStopSize: CGFloat = 32,
        captureButtonStrokeWidth: CGFloat = 4,
        iconFontSize: CGFloat = 20,
        sideButtonWidth: CGFloat = 72,
        horizontalPadding: CGFloat = 16,
        topPadding: CGFloat = 8,
        captureButtonTopPadding: CGFloat = 16,
        captureButtonBottomPadding: CGFloat = 32,
        actionsBottomPadding: CGFloat = 16,
        modeSpacing: CGFloat = 16,
        actionSpacing: CGFloat = 24
    ) {
        self.backgroundColor = backgroundColor
        self.chromeBackgroundColor = chromeBackgroundColor
        self.accentColor = accentColor
        self.recordingColor = recordingColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.iconButtonBackground = iconButtonBackground
        self.iconButtonSize = iconButtonSize
        self.captureButtonOuterSize = captureButtonOuterSize
        self.captureButtonInnerSize = captureButtonInnerSize
        self.captureButtonStopSize = captureButtonStopSize
        self.captureButtonStrokeWidth = captureButtonStrokeWidth
        self.iconFontSize = iconFontSize
        self.sideButtonWidth = sideButtonWidth
        self.horizontalPadding = horizontalPadding
        self.topPadding = topPadding
        self.captureButtonTopPadding = captureButtonTopPadding
        self.captureButtonBottomPadding = captureButtonBottomPadding
        self.actionsBottomPadding = actionsBottomPadding
        self.modeSpacing = modeSpacing
        self.actionSpacing = actionSpacing
    }

    public static let `default` = CameraViewStyle()
}

#endif
