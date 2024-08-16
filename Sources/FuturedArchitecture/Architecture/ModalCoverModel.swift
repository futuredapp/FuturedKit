//
//  ModalCoverModel.swift
//  
//
//  Created by Simon Sestak on 01/08/2024.
//

import Foundation

public struct ModalCoverModel<Destination: Hashable & Identifiable>: Identifiable {
    let destination: Destination
    let style: Style

    public enum Style {
        case sheet
        #if !os(macOS)
        case fullscreenCover
        #endif
    }

    public var id: Destination.ID {
        destination.id
    }
}
