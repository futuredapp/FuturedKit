//  ___FILEHEADER___

import SwiftUI

struct ___VARIABLE_sceneIdentifier___Component<Model: ___VARIABLE_sceneIdentifier___ComponentModelProtocol>: View {
    @State var model: Model

    var body: some View {
        ComponentStateView(state: model.projection.state) {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        } emptyView: {
            Text("No data available")
        } errorView: { config in
            Text(config.title)
        }
        .task {
            await model.onAppear()
        }
    }
}

#if DEBUG
#Preview {
    ___VARIABLE_sceneIdentifier___Component(
        model: ___VARIABLE_sceneIdentifier___ComponentModelMock()
    )
}
#endif
