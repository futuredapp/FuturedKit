//
//  QueueAction.swift
//
//
//  Created by Simon Sestak on 11/10/2024.
//

import Foundation

public protocol QueueAction: Identifiable {
    /// Priority, which defines the order of actions addition to the queue
    var priority: QueueActionPriority { get }
}

public enum QueueActionPriority {
    /// Appended to the end of the queue
    case normal
    /// Added to the start of the queue, but after `highest`
    /// If there is already a `high` priority action in the queue, new action will be added after it
    case high
    /// Added to the start of the queue
    /// If there is already a `highest` priority action in the queue, new action will be added after it
    case highest
    /// Queue will replace all its elements when receives an action with `replaceAll` priority
    case replaceAll

    public var higher: Self? {
        switch self {
        case .normal:
            return .high
        case .high:
            return .highest
        case .highest:
            return .replaceAll
        case .replaceAll:
            return nil
        }
    }
}
