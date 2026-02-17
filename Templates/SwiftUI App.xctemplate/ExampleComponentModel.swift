//  ___FILEHEADER___

import FuturedArchitecture
import Observation

protocol ExampleComponentModelProtocol: ComponentModel {
    func onAppear() async
    func onTouchUpInside()
}

@Observable
final class ExampleComponentModel: @MainActor ExampleComponentModelProtocol {

    let onEvent: (Event) -> Void

    private let dataCache: DataCache<DataCacheModel>

    init(
        dataCache: DataCache<DataCacheModel>,
        onEvent: @escaping (Event) -> Void
    ) {
        self.dataCache = dataCache
        self.onEvent = onEvent
    }

    func onAppear() async {
        // Subscribe to dataCache changes
        // Fetch fresh data
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
final class ExampleComponentModelMock: @MainActor ExampleComponentModelProtocol {
    typealias Event = ExampleComponentModel.Event

    var onEvent: (Event) -> Void = { _ in }

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
