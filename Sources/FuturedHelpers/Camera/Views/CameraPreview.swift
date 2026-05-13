#if canImport(UIKit)

import AVFoundation
import SwiftUI
import UIKit

/// SwiftUI wrapper around `AVCaptureVideoPreviewLayer`.
public struct CameraPreview: UIViewRepresentable {
    private let session: AVCaptureSession
    private let videoGravity: AVLayerVideoGravity

    public init(session: AVCaptureSession, videoGravity: AVLayerVideoGravity = .resizeAspectFill) {
        self.session = session
        self.videoGravity = videoGravity
    }

    public func makeUIView(context: Context) -> CameraContainerView {
        let view = CameraContainerView()
        view.backgroundColor = .black
        view.previewLayer.session = session
        view.previewLayer.videoGravity = videoGravity
        return view
    }

    public func updateUIView(_ uiView: CameraContainerView, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
        uiView.previewLayer.videoGravity = videoGravity
    }

    public final class CameraContainerView: UIView {
        override public static var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        public var previewLayer: AVCaptureVideoPreviewLayer {
            // swiftlint:disable:next force_cast
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}

#endif
