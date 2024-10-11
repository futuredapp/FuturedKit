//
//  ActionsCache.swift
//
//
//  Created by Simon Sestak on 11/10/2024.
//

import FuturedArchitecture
import Combine

actor ActionsCache<A: QueueAction> {
    let subject: CurrentValueSubject<A?, Never> = CurrentValueSubject(nil)

    private var actions = [A]() {
        didSet {
            subject.send(actions.first)
        }
    }

    var currentAction: A? {
        actions.first
    }

    func add(action: A) {
        // If there is already an action with the same id, just replace it with new one
        if let index = actions.firstIndex(where: { $0.id == action.id }) {
            actions[index] = action

            // Else, append it regarding to its priority
        } else {
            switch action.priority {
            case .normal:
                actions.append(action)
            case .high, .highest:
                if let index = indexForAction(withPriority: action.priority) {
                    actions.insert(action, at: index)
                } else {
                    actions.insert(action, at: 0)
                }
            case .replaceAll:
                actions = [action]
            }
        }
    }

    func replaceFirstAction(where oldAction: (A) -> Bool, with newAction: A) {
        if let index = actions.firstIndex(where: oldAction) {
            actions[index] = newAction
        } else {
            add(action: newAction)
        }
    }

    func finishCurrent() {
        if !actions.isEmpty {
            actions.removeFirst()
        }
    }

    func finishAll(where condition: (A) -> Bool) {
        actions.removeAll(where: condition)
    }

    func finishAll() {
        actions.removeAll()
    }

    private func indexForAction(withPriority priority: QueueActionPriority) -> Int? {
        guard let lastIndex = actions.lastIndex(where: { $0.priority == priority }) else {
            if let higherPriority = priority.higher {
                return indexForAction(withPriority: higherPriority)
            } else {
                return nil
            }
        }

        return actions.index(after: lastIndex)
    }
}

