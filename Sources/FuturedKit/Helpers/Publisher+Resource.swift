import Combine

extension Publisher {
    /// Transforms all elements and failures to ``Resource``.
    /// - Returns: Upstream publisher wrapped using map and catch operators
    ///   with ``Resource`` as output type and `Never` as failure.
    @inlinable
    public func resource() -> Publishers.Catch<
        Publishers.Map<Self, Resource<Output, Failure>>, Just<Resource<Output, Failure>>
    > {
        map { output in
            Resource(content: output)
        }
        .catch { error in
            Just(Resource(error: error))
        }
    }
}
