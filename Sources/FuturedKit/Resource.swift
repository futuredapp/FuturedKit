public struct Resource<Content, Failure: Error> {
    public var content: Content?
    public var isLoading: Bool
    public var error: Failure?

    public init(content: Content? = nil) {
        self.content = content
        self.isLoading = false
        self.error = nil
    }

    public init(error: Failure) {
        self.content = nil
        self.isLoading = false
        self.error = error
    }

    public var isRefreshing: Bool {
        isLoading && hasContent
    }

    public var hasContent: Bool {
        content != nil
    }

    public var hasFailed: Bool {
        error != nil
    }
}

