/// Represents asynchronous action which does not load data
///
/// ## Overview
///
/// This is ideal for observing state of remote action in any app.
public enum Action<Failure: Error>: AsynchronousOperation {
    case inactive, loading, success, failure(Failure?)
}

extension Action: Equatable {
    /// Note: equatable does not compare `Failure` type
    public static func == (lhs: Action<Failure>, rhs: Action<Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.failure, .failure):
            return true
        default:
            return false
        }
    }
}
