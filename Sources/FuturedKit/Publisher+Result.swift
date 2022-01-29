import Combine

extension Publisher {
    /// Transforms all elements and failures to ``Result``.
    /// - Returns: Upstream publisher wrapped using map and catch operators
    ///   with ``Result<Output, Failure>`` as output type and `Never` as failure.
    @inlinable
    public func result() -> Publishers.Catch<Publishers.Map<Self, Result<Output, Failure>>, Just<Result<Output, Failure>>> {
        map { output in
            Result.success(output)
        }
        .catch { error in
            Just(Result.failure(error))
        }
    }
}
