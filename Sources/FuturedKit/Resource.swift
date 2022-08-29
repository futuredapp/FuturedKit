/// Represents asynchronously loaded data and their state
/// including loading, errors and even refreshing.
///
/// ## Overview
///
/// States are not exclusive, you can even have error and content
/// if its required to represent error which happened during
/// refreshing.
///
/// This is ideal for modelling state for remotely loaded resource
/// in any app.
public struct Resource<Content, Failure: Error>: AsynchronousOperation {
    /// Content if it was loaded.
    public var content: Content?
    /// Flag representing if the resource is currently loading.
    public var isLoading: Bool
    /// Optional strongly-typed error which occured during the load or refresh.
    public var error: Failure?

    /// Created a new resource.
    /// - Parameters:
    ///   - content: Optional content. Default value is `nil`.
    ///   - isLoading: Loading flag. Default value is `false`.
    ///   - error: Optional error. Default value is `nil`.
    public init(content: Content? = nil, isLoading: Bool = false, error: Failure? = nil) {
        self.content = content
        self.isLoading = isLoading
        self.error = error
    }

    /// Read-only flag representing if the content is refreshing.
    ///
    /// ## Discussion
    ///
    /// The flag is set to true when the resource is loading and has some content.
    public var isRefreshing: Bool {
        isLoading && hasContent
    }

    /// Read-only flag representing if the content is present.
    public var hasContent: Bool {
        content != nil
    }

    /// Read-only flag representing if some error occured.
    public var hasFailed: Bool {
        error != nil
    }
}
