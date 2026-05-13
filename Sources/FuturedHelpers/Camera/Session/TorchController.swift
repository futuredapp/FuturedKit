#if canImport(UIKit)

import AVFoundation
import Foundation

/// Applies a torch mode to the active capture device. Must be called on the
/// owning session queue because it locks the device for configuration.
enum TorchController {
    static func apply(_ flashMode: FlashMode, to device: AVCaptureDevice?) {
        guard let device, device.hasTorch,
              (try? device.lockForConfiguration()) != nil else {
            return
        }
        device.torchMode = flashMode.avTorchMode
        device.unlockForConfiguration()
    }
}

#endif
