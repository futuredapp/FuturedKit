//
//  ModalCoverModel.swift
//
//
//  Created by Simon Sestak on 01/08/2024.
//

import Foundation
import SwiftUI

public enum SheetDetent: Hashable {
    case medium
    case large
    case fraction(CGFloat)

    func detent() -> PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        case let .fraction(fraction):
            return .fraction(fraction)
        }
    }
}

/// Style of the modally presented view.
///
/// It is intended to be used with ``ModalCoverModel``. Style has been placed to
/// the global scope, since the Model is generic.
public enum ModalCoverModelStyle {
    case sheet
    #if !os(macOS)
    case fullscreenCover
    #endif
}

/// This struct is a model associating presentation style with a destination on a specific ``Coordinator``.
public struct ModalCoverModel<Destination: Hashable & Identifiable>: Identifiable {
    public let destination: Destination
    public let style: ModalCoverModelStyle
    public let zoomSourceID: AnyHashable?

    public var id: Destination.ID {
        destination.id
    }

    public init(destination: Destination, style: ModalCoverModelStyle) {
        self.destination = destination
        self.style = style
        zoomSourceID = nil
    }

    public init(destination: Destination, style: ModalCoverModelStyle, zoomSourceID: some Hashable) {
        self.destination = destination
        self.style = style
        self.zoomSourceID = AnyHashable(zoomSourceID)
    }
}
