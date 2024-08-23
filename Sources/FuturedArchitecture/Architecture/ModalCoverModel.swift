//
//  ModalCoverModel.swift
//  
//
//  Created by Simon Sestak on 01/08/2024.
//

import Foundation

public enum ModalCoverModelStyle {
    case sheet
    #if !os(macOS)
    case fullscreenCover
    #endif
}

public struct ModalCoverModel<Destination: Hashable & Identifiable>: Identifiable {
    public let destination: Destination
    public let style: ModalCoverModelStyle
    
    public var id: Destination.ID {
        destination.id
    }
}
