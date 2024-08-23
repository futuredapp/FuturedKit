import Foundation

/// `ComponentModel` is an analogy to `ViewModel`. Each *compoenent model* should have
/// it's own protocol which uses the `ComponentModel` protocol as it's requirement. This allows us
/// to create a Mock implementations of compoenent models and allow for simpler and more scalable
/// SwiftUI Previews.
///
/// As is eluded to by `ComponentModel`, each component model has two main competencies:
///  - Hold and organize data required by the associated view.
///  - Receive events from the associated view and propagate them upwards to a *coordinator.*
///
/// The associated type `Event` is just an `enum` in most cases, but we do not explicitly discourage
/// you from using *any* type you see fit. However, keep in mind, that we should not burden *coordinators*
/// with too much logic. Keep the API for the *coordinators* simple.
///
/// - Note: Each *component model* should have have *mock* class and *implementation* class.
/// Each *Component* (i.e. View) should have own *component model*. Each instance of component
/// model has to be referenced by no more than 1 *coordinator.*
public protocol ComponentModel: ObservableObject {
    
    /// Type used to pass events to the *coordinator*. `enum` is used in most cases, but not required.
    associatedtype Event

    /// Closure which should be provided by the *coordinator* and only invoked from within the
    /// *component model* instance.
    ///
    /// The return type if this closure is `Void` intentionally. If bidirectional communication is
    /// desired, either pass closure to the *coordinator* using the event, or use other
    /// recommended pattern of data flow.
    var onEvent: (Event) -> Void { get }
}
