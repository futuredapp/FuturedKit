//  ___FILEHEADER___

import SwiftUI

struct ExampleComponent<Model: ExampleComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        ComponentStateView(state: model.projection.state) {
            VStack {
                Text(model.projection.title)

                Button("Hello, World!") {
                    model.onTouchUpInside()
                }
            }
        } emptyView: {
            Text("No data available")
        } errorView: { config in
            VStack {
                Text(config.title)

                if let retryConfig = config.retryConfig {
                    Button(retryConfig.title) {
                        Task {
                            await retryConfig.action()
                        }
                    }
                }
            }
        }
        .task {
            await model.onAppear()
        }
    }
}

#if DEBUG
#Preview {
    ExampleComponent(
        model: ExampleComponentModelMock()
    )
}
#endif
