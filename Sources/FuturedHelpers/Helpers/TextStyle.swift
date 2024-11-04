import SwiftUI

// MARK: - TextStyle

/// A structure that represents a text style.
/// Use this structure to define a text style with a specific font, size, line height, font scaling, letter spacing, text case, and text decoration.
/// You can apply the text style to a view using the `textStyle(_:)` modifier or to a text using the `textStyleText(_:)` modifier if you need to apply a text style to a `Text` specifically.
/// Additionally, you can apply the text style to an attributed string using the `stylize(with:)` method or initialize an attributed string with the text style using the `NSAttributedString` initializer.
/// Example:
/// ```swift
/// extension TextStyle {
///     static let title = TextStyle(
///         fontType: .system(weight: .bold),
///         size: 24,
///         lineHeight: 32,
///         scaling: .relativeTo(textStyle: .title),
///         letter: .relative(percent: 5),
///         textCase: .uppercase,
///         textDecoration: .underline
///     )
/// }
///
/// struct ExampleView: View {
///     var body: some View {
///         Text("Title")
///             .textStyle(.title)
///     }
/// }
/// ```
/// - Note: The `textStyleText(_:)` modifier does not apply line spacing, text case, or vertical padding based on line height.
/// - Note: The `stylize(with:)` method does not apply line spacing, text case, or vertical padding based on line height.
/// - Note: The `NSAttributedString` initializer does not apply line spacing, text case, or vertical padding based on line height.
public struct TextStyle {
    
    /// An enumeration that represents a type of font for a text style.
    public enum FontType {

        /// A custom font specified by its name.
        /// - Parameter name: The name of the font to be used.
        case custom(name: String)
        
        /// A system font specified by its weight and width.
        /// - Parameters:
        ///  - weight: The weight of the system font.
        ///  - width: The width of the system font. Default is `.standard`.
        case system(weight: Font.Weight, width: Font.Width = .standard)
    }
    
    /// An enumeration that represents a type of font scaling for a text style.
    public enum FontScaling {
        
        /// The default font scaling using default font metrics object.
        case `default`
        
        /// The fixed size font scaling without any scaling.
        case fixedSize
        
        /// The font scaling relative to the specified text style.
        /// - Parameter textStyle: The text style to which the font scaling is relative.
        case relativeTo(textStyle: Font.TextStyle)
        
        /// The font metrics object for the specified font scaling.
        public var fontMetrics: UIFontMetrics? {
            switch self {
            case .default:
                .default
            case .fixedSize:
                nil
            case .relativeTo(let textStyle):
                .init(forTextStyle: textStyle.uiFontTextStyle)
            }
        }
    }
    
    /// An enumeration that represents a type of letter spacing for a text style.
    public enum Letter {
        
        /// The relative letter spacing expressed as a percentage of the font size.
        /// - Parameter percent: The percentage of the font size for the relative letter spacing.
        case relative(percent: CGFloat)
        
        /// The absolute letter spacing expressed in points.
        /// - Parameter points: The points for the absolute letter spacing.
        case absolute(points: CGFloat)
    }

    /// An enumeration that represents a type of text decoration for a text style.
    public enum TextDecoration: String {
        
        /// The underline text decoration.
        case underline
        
        /// The strikethrough text decoration.
        case strikethrough
    }

    /// The type of font for the text style.
    public let fontType: FontType

    /// The size of the font for the text style.
    public let size: CGFloat

    /// The line height of the font for the text style.
    public let lineHeight: CGFloat
    
    /// The font scaling for the text style.
    public let scaling: FontScaling
    
    /// The letter spacing for the text style.
    public let letter: Letter
    
    /// The text case for the text style.
    public let textCase: Text.Case?
    
    /// The text decoration for the text style.
    public let textDecoration: TextDecoration?
    
    /// The line spacing of the font for the text style.
    public var lineSpacing: CGFloat {
        (scaling.fontMetrics?.scaledValue(for: lineHeight) ?? lineHeight) - (scaling.fontMetrics?.scaledValue(for: uiFont.lineHeight) ?? uiFont.lineHeight)
    }

    /// The font for the text style.
    public var font: Font {
        switch fontType {
        case .custom(let name):
            switch scaling {
            case .default:
                .custom(name, size: size)
            case .fixedSize:
                .custom(name, fixedSize: size)
            case .relativeTo(let textStyle):
                .custom(name, size: size, relativeTo: textStyle)
            }
        case .system(let weight, let width):
            .system(size: scaling.fontMetrics?.scaledValue(for: size) ?? size, weight: weight).width(width)
        }
    }

    /// The `UIFont` for the text style.
    public var uiFont: UIFont {
        switch fontType {
        case .custom(let name):
            let font = UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
            return scaling.fontMetrics?.scaledFont(for: font) ?? font
        case .system(let weight, let width):
            return .systemFont(
                ofSize: scaling.fontMetrics?.scaledValue(for: size) ?? size,
                weight: weight.uiFontWeight,
                width: width.uiFontWidth
            )
        }
    }
    
    /// The kerning of the font for the text style.
    public var kerning: CGFloat {
        switch letter {
        case .relative(let percent):
            (scaling.fontMetrics?.scaledValue(for: lineHeight) ?? lineHeight) * (percent / 100.0)
        case .absolute(let pixels):
            scaling.fontMetrics?.scaledValue(for: pixels) ?? pixels
        }
    }

    /// Initializes a text style with the specified properties.
    /// - Parameters:
    ///  - fontType: The type of font for the text style.
    ///  - size: The size of the font for the text style.
    ///  - lineHeight: The line height of the font for the text style.
    ///  - scaling: The font scaling for the text style. Default is `.default`.
    ///  - letter: The letter spacing for the text style. Default is `.absolute(points: 0)`.
    ///  - textCase: The text case for the text style. Default is `nil`.
    ///  - textDecoration: The text decoration for the text style. Default is `nil`.
    public init(
        fontType: FontType,
        size: CGFloat,
        lineHeight: CGFloat,
        scaling: FontScaling = .default,
        letter: Letter = .absolute(points: 0),
        textCase: Text.Case? = nil,
        textDecoration: TextDecoration? = nil
    ) {
        self.fontType = fontType
        self.size = size
        self.lineHeight = lineHeight
        self.scaling = scaling
        self.letter = letter
        self.textCase = textCase
        self.textDecoration = textDecoration
    }
}

// MARK: - Extensions

extension View {
    /// Applies the specified text style to the view.
    /// - Parameter style: The text style to apply to the view.
    /// - Returns: A view that applies the specified text style.
    public func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .kerning(style.kerning)
            .underline(style.textDecoration == .underline)
            .strikethrough(style.textDecoration == .strikethrough)
            .textCase(style.textCase)
            .padding(.vertical, style.lineSpacing / 2)
    }
}

extension Text {
    /// Applies the specified text style to the text.
    /// Use this modifier when you need to apply a text style to a `Text`, rather than to a generic View.
    /// - Parameter style: The text style to apply to the text.
    /// - Returns: A text that applies the specified text style.
    /// - Note: This modifier does not apply line spacing, text case, or vertical padding based on line height.
    public func textStyleText(_ style: TextStyle) -> Text {
        self
            .font(style.font)
            .kerning(style.kerning)
            .underline(style.textDecoration == .underline)
            .strikethrough(style.textDecoration == .strikethrough)
    }
}

extension AttributedStringProtocol {
    /// Applies the specified text style to the attributed string.
    /// - Parameter style: The text style to apply to the attributed string.
    /// - Returns: An attributed string that applies the specified text style.
    /// - Note: This method does not apply line spacing, text case, or vertical padding based on line height.
    public mutating func stylize(with style: TextStyle) {
        self.font = style.font
        self.kern = style.kerning
        self.underlineStyle = style.textDecoration == .underline ? .single : nil
        self.strikethroughStyle = style.textDecoration == .strikethrough ? .single : nil
    }
}

extension NSAttributedString {
    /// Initializes an attributed string with the specified properties.
    /// - Parameters:
    /// - string: The string for the attributed string.
    /// - textStyle: The text style for the attributed string.
    /// - additionalAttributes: The additional attributes for the attributed string. Default is `nil`.
    public convenience init(
        string: String,
        textStyle: TextStyle,
        additionalAttributes: [NSAttributedString.Key: Any]? = nil
    ) {
        self.init(
            string: string,
            attributes: [
                .font: textStyle.uiFont,
                .kern: textStyle.kerning,
            ]
        )
    }
}
