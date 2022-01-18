import Combine

extension Publisher {
    @inlinable
    public func resource() -> Publishers.Catch<Publishers.Map<Self, Resource<Output, Failure>>, Just<Resource<Output, Failure>>> {
        map { output in
            Resource(content: output)
        }
        .catch { error in
            Just(Resource(error: error))
        }
    }
}
