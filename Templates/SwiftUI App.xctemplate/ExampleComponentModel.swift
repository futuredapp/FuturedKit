//  ___FILEHEADER___

import FuturedArchitecture
import Observation

protocol ExampleComponentModelProtocol: ComponentModel {
    func onAppear() async
    func onTouchUpInside()
}

@Observable
final class ExampleComponentModel: ExampleComponentModelProtocol {

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
        // Access dataCache.value (or its properties) directly — observation is automatic.
        // Fetch fresh data here if needed.
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

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
