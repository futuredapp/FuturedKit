//
//  ModalCoverModel.swift
//
//
//  Created by Simon Sestak on 01/08/2024.
//

import SwiftUI
import Foundation


public enum SheetDetent: Hashable {
    case medium
    case large
    case height
    case fraction(CGFloat)

    func detent(size: CGSize) -> PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        case .height:
            return .height(size.height)
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
    case sheet(detents: Set<SheetDetent>? = nil)
    #if !os(macOS)
    case fullscreenCover
    #endif


    func detents(size: CGSize) -> Set<PresentationDetent>? {
        if case let .sheet(detents) = self, let detents {
            return Set(detents.map { $0.detent(size: size) })
        }
        return nil
    }

    var isSheet: Bool {
        if case .sheet = self {
            return true
        }
        return false
    }

    var hasDetents: Bool {
        if case let .sheet(detents) = self {
            return detents != nil
        }
        return false
    }
}

/// This struct is a model associating presentation style with a destination on a specific ``Coordinator``.
public struct ModalCoverModel<Destination: Hashable & Identifiable>: Identifiable {
    public let destination: Destination
    public let style: ModalCoverModelStyle
    
    public var id: Destination.ID {
        destination.id
    }

    public init(destination: Destination, style: ModalCoverModelStyle) {
        self.destination = destination
        self.style = style
    }
}
