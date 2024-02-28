//  ___FILEHEADER___

import SwiftUI

struct BaseComponent<Model: BaseComponentModelProtocol>: View {
    @StateObject var model: Model

    var body: some View {
        Button("Hello, World!") {
            model.onTouchUpInside()
        }
        .task {
            await model.onAppear()
        }
    }
}

#if DEBUG
#Preview {
    BaseComponent(
        model: BaseComponentModelMock()
    )
}
#endif
