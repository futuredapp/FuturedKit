# FuturedKit

SwiftUI state management tools, resources and views used by Futured.

## Features

### Architecture

- ``Coordinator``
    - The Coordinator protocol defines a destination type (instances are hashable and identifiable), root view and destination views that conform to the `View` protocol, and properties for a sheet, fullscreen cover and alert model. Furthermore, it provides methods for presenting/dismissing sheets and fullscreen covers, displaying alerts, handling the dismissal of sheets and fullscreen covers.
    - ``TabCoordinator``
        - The `TabCoordinator` protocol extends the `Coordinator` protocol and provides additional functionality for managing tab views in SwiftUI apps. It introduces a `Tab` associated type and a `selectedTab` property which is used for managing the currently selected tab.
    - ``NavigationStackCoordinator``
        - The `NavigationStackCoordinator` protocol also extends the `Coordinator` protocol and adds additional functionality for managing navigation stacks in SwiftUI apps. It manages a `path` which represents the array of navigational elements in the navigation stack, and provides methods for moving through this navigation stack. Actions such as navigate (to push a new view onto the stack), pop (to remove the current view from the stack), and pop to a specific destination in the stack are defined in this protocol.
- ``Component``
    - Components are the views that users interact with directly in the application. They handle the user interface and its functionality. From buttons to table views, every element a user sees and interacts with is a separate View in our application. Our aim here is to keep our Components as simple and clean as possible to provide a clutter-free and intuitive user interface.
    - Components are designed to hold multiple view elements which can be reusable in other components. When a user interacts with a component action view (button, text field delegates, etc.), they call the ComponentModel functions for the desired behavior.
- ``ComponentModel``
    - ComponentModels act as an intermediary between Components and Models. In our iOS application, they handle the business logic and are in charge of making API calls, parsing data, managing and performing computations. Typically, the ComponentModel will format the data it receives from the Model so that it's ready to be presented by the View.
- ``DataCacheModel``
    - DataCacheModel is a component in our application's architecture whose function is to store and retrieve data in a fast and efficient manner. It saves user information or data from server responses, which can then be readily accessed when needed. The advantage of DataCacheModel is that it reduces the need for repetitive network calls, providing a smoother user experience.
    - Use DataCacheModel for every DataModel which needs to be stored for multiple app flows or for app flows which can be reopened. For use cases like creating a new DataModel which is specific for one flow, create a new DataCache wrapper that wraps the DataModel in this specific flow coordinator.

### Views

- ``AnyShape``
- ``WrappedUIImagePicker``
- ``CameraImagePicker``
- ``GalleryImagePicker``

## Installation

When using Swift package manager install using or add following line to your dependencies:

```swift
.package(url: "https://github.com/futuredapp/FuturedKit.git", from: "1.0.0")
```

## Contributions

All contributions are welcome.

Current maintainer and main contributor is [Ievgen Samoilyk](https://github.com/samoilyk), <ievgen.samoilyk@futured.app>.

## License

FuturedKit is available under the MIT license. See the [LICENSE file](LICENSE) for more information.
