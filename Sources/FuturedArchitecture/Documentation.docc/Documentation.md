# FuturedKit

The FuturedKit Architecture is a flow-coordinator, component, component model based architecture. The architecture uses Combine and Swift Concurrency for state management. Originally, we wanted to use Swift Concurrency with Observable, but we needed to backport the architecture to iOS 16.

## Main concepts

This architecture uses some concepts which may be familiar, but we decided to modify the usual naming (mainly due to naming conflits with existing APIs).

![overview](Images/archoverview.svg)

### Scene

*Scene* is the basic building block of the architecture and comprises of two main building blocks: `Component` and `ComponentModel`.

- `Component` is a struct conforming to ``SwiftUI.View``. It has generic parameter `Model` which is used to represent the `ComponentModel` of this scene. The `model` is retained as an `ObservableObject`.
- `ComponentModel` consists of three parts: `ComponentModelProtocol`, `MockComponentModel` and the `ComponentModel` itself. We use this decomposition so we can create mocked component model for better SwiftUI Previews experience.
  - `ComponentModelProtocol` defines the properties required by the `Component`. It also defines functions, which the `Component` may call in response to an event, such as a button tap. All `ComponentModelProtocol` are required to extend the ``ComponentModel`` protocol.
  - `MockComponentModel` should be only used in debug builds (use `#if DEBUG`) and as compact as possible to allow for responsive SwiftUI Previews.
  - `ComponentModel` is the implementation of `ComponentModelProtocol` and is responsible for storing the data, sending events to the ``Coordinator`` and subscribing to changes which may be relevant for this scene.

### Flow Coordinator

*Flow Coordinator* is a class which manages creation, lifetime and data flows in child-scenes of a container (such as Navigation or Tab). A *flow coordinator* may be also looked upon as a "view model of a container view." All coordinators are required to conform to ``Coordinator`` protocol, but we provide implementations for the most commonly used containers:

 - ``NavigationStackCoordinator`` and associated view ``NavigationStackFlow`` is used for Navigation.
 - ``TabCoordinator`` and associated view ``TabViewFlow`` is used for Tabs.

Flow coordinators are also responsible for presentation of modal views.

### Container

Container is not defined as a type or a protocol, but is a part of the architecture. It is used for dependency management. In essence, *container* is only required to be an instance of a class, hold references to all globally accessible instances (for example Services). 

### Data Cache

``DataCache`` is an actor holding an equatable structure. It is responsible for managing the structure as a source of truth, serializing write operations and exposing the contents as a `Published` variable, so consuments can subscribe to changes. Data cache may be used to store data shared across the app or cache results of an API calls.

Each application should have one global data cache stored in the `Container`. Individual Coordinators may have their own private Data Caches to coordinate data flows across child scenes.

**Data stored in Data Cache should be directly the source of truth for views, or mapped using a subscription.**

### Flow Provider

Flow providers are optional part of the architecture. It may be used to encapsulate parts of a flow, which may be used in number of coordinators. For more information, visit ``CoordinatorSceneFlowProvider`` and related template.

## Data Flows

The idea behind data flows in the Architecture is fairly simple: use closures when talking to a parent, arguments when passing immutable data from parent to a child and multidelegates (such as Published properties) when data passed from parent to a child a subject to change. Below are described some suggestions on how to impement data flows for certain scenarios.

### Component <-> Component Model

### Component Model <-> Coordinator

### Component Model <-> Component Model

### Component Model -> Component Model using navigation

### Persisted data models

Data Flow for persisted data is an open issue.
