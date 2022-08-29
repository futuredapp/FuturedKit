/// Protocol used for representing asynchronous operation

public protocol AsynchronousOperation {
    var isLoading: Bool { get }
    var hasFailed: Bool { get }
}
