/// Protocol used for representing asynchronous operation

public protocol AsynchronousOperation {
    associatedtype Failure: Error

    var isLoading: Bool { get }
    var hasFailed: Bool { get }
    var error: Failure? { get }
}
