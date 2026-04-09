//  ___FILEHEADER___

import FuturedArchitecture
import Observation

protocol ExampleComponentModelProtocol: ComponentModel {
    var projection: ExampleCacheProjection { get }
    func onAppear() async
    func onTouchUpInside()
}

@Observable
final class ExampleComponentModel: ExampleComponentModelProtocol {

    let onEvent: (Event) -> Void

    private let dataCache: DataCache<DataCacheModel>

    /// Computed projection: automatically observes dataCache.value changes
    /// via @Observable tracking. No Combine subscription needed.
    var projection: ExampleCacheProjection {
        ExampleCacheProjection.data(from: dataCache.value) ?? .empty(state: .loading)
    }

    init(
        dataCache: DataCache<DataCacheModel>,
        onEvent: @escaping (Event) -> Void
    ) {
        self.dataCache = dataCache
        self.onEvent = onEvent
    }

    func onAppear() async {
        // Fetch fresh data from network and update dataCache
    }

    func onTouchUpInside() {
        onEvent(.touchEvent)
    }
}

extension ExampleComponentModel {
    enum Event {
        case touchEvent
    }
}

#if DEBUG
@Observable
final class ExampleComponentModelMock: ExampleComponentModelProtocol {
    typealias Event = ExampleComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }
    var projection: ExampleCacheProjection = .empty(state: .ready)

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
