//
//  ActionsQueue.swift
//  
//
//  Created by Simon Sestak on 11/10/2024.
//

import Combine
import FuturedArchitecture
import Foundation

/// Actions queue which emits new first action using publisher property after current first action is removed
public class ActionsQueue<A: QueueAction> {
    /**
     - Subscribe on change of the first element in queue
     - Will emit new action after the current first action in queue was removed
     - Ignores duplicates of the same element
     */
    public let publisher: AnyPublisher<A?, Never>

    private var actionsCache: ActionsCache<A>
    private var cancellable: AnyCancellable?

    /**
     Init the queue to assign its changes to @Published property, which triggers ui updates automatically

     - Parameters:
     - published: @Published.Publisher property which is assigned to action queue publisher. Typically @Published property, that is responsible for presenting alerts, sheets, covers, toasts etc.
     */
    public init(publisher: inout Published<A?>.Publisher) {
        self.actionsCache = ActionsCache()
        self.publisher = actionsCache.subject
            .removeDuplicates { $0?.id == $1?.id }
            .eraseToAnyPublisher()

        // Send actions to @Published property
        self.publisher
            .receive(on: DispatchQueue.main)
            .assign(to: &publisher)

        // If @Published property is set to nil, remove first action from queue if present
        self.cancellable =
        publisher
            .map { $0 == nil }
            .removeDuplicates()
            .sink(receiveValue: removeFirstIfNecessary)
    }

    /// Current action in queue (the first one in the array of actions)
    public func currentAction() async -> A? {
        await actionsCache.currentAction
    }

    /// Adds actions to queue
    /// If there is already an action with the same id, just replace it with new one
    public func add(action: A) async {
        await actionsCache.add(action: action)
    }

    /// Removes first action in queue
    public func finishCurrent() async {
        await actionsCache.finishCurrent()
    }

    /// Removes all actions, which matches given condition
    public func finishAll(where condition: (A) -> Bool) async {
        await actionsCache.finishAll(where: condition)
    }

    public func finishAll() async {
        await actionsCache.finishAll()
    }

    /// Replaces first found action in array, that matches given condition, with new one
    public func replaceFirstAction(where oldAction: (A) -> Bool, with newAction: A) async {
        await actionsCache.replaceFirstAction(where: oldAction, with: newAction)
    }

    private func removeFirstIfNecessary(isNil: Bool) {
        if isNil {
            Task { await finishCurrent() }
        }
    }
}
