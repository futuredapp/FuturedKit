//  ___FILEHEADER___

import FuturedArchitecture

protocol ExampleComponentModelProtocol: ComponentModel {
    func onAppear() async
    func onTouchUpInside()
}

final class ExampleComponentModel: ExampleComponentModelProtocol {

    let onEvent: @MainActor (Event) -> Void

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
        Task {
            await onEvent(.touchEvent)
        }
    }
}

extension ExampleComponentModel {
    enum Event {
        case touchEvent
    }
}

#if DEBUG
final class ExampleComponentModelMock: ExampleComponentModelProtocol {
    typealias Event = ExampleComponentModel.Event

    var onEvent: @MainActor (Event) -> Void = { _ in }

    func onAppear() async { }

    func onTouchUpInside() { }
}
#endif
