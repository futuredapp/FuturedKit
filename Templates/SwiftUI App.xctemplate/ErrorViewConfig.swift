//  ___FILEHEADER___

import Foundation

struct ErrorViewConfig: Error, Equatable {
    struct RetryActionConfig: Equatable {
        let title: String
        let action: @Sendable () async -> Void

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.title == rhs.title
        }
    }

    let title: String
    let subtitle: String?
    let retryConfig: RetryActionConfig?

    init(title: String, subtitle: String? = nil, retryConfig: RetryActionConfig? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.retryConfig = retryConfig
    }
}
