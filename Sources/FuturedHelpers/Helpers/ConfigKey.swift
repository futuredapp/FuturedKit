import Foundation

/// Protocol for configuration keys that provides default implementation for retrieving values from Info.plist
/// with automatic Base64 decoding support
public protocol ConfigKey: RawRepresentable where RawValue == String {
    /// Default implementation that retrieves and decodes values from Info.plist
    var value: String { get throws }
}

public extension ConfigKey {
    /// Default implementation that reads from Info.plist and handles Base64 decoding
    var value: String {
        get throws {
            guard let rawValue = Bundle.main.object(forInfoDictionaryKey: rawValue) as? String else {
                throw ConfigKeyError.valueNotFound(key: rawValue)
            }

            // Try to decode as Base64, fallback to original value if not encoded
            guard let data = Data(base64Encoded: rawValue),
                  let decodedString = String(data: data, encoding: .utf8) else {
                // Not valid Base64, return original value
                return rawValue
            }
            return decodedString
        }
    }
}

/// Error type for configuration key handling
public enum ConfigKeyError: LocalizedError {
    case valueNotFound(key: String)

    public var errorDescription: String? {
        switch self {
        case let .valueNotFound(key):
            "Value for \"\(key)\" was not found in .xcconfig file. Check if the value with this key is imported from GitHub secrets to .xcconfig file and whether it is specified in Info.plist."
        }
    }
}
