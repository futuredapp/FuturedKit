//  ___FILEHEADER___

import SwiftUI

struct ExampleComponent<Model: ExampleComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        ComponentStateView(state: model.projection.state) {
            content
        }
        .task {
            await model.onAppear()
        }
    }

    private var content: some View {
        VStack {
            Text(model.projection.title)

            Button("Hello, World!") {
                model.onTouchUpInside()
            }
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
