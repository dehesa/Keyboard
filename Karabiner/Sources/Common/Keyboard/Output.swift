import Foundation

public extension Keyboard {
    ///
    public struct Output: Codable {
        ///
    }
}

public extension Keyboard.Output {
    /// type of output expected from the virtual keyboard.
    public enum Kind {
        /// A key press (with its associated key code).
        case key(Keyboard.Key)
        /// A mouse button.
        case button(Keyboard.Button)
        /// A customer specific key code.
        case custom(String)
        /// A shell command to be executed on the terminal.
        case shell(String)
        /// Change keyboard input source (e.g. language, source identifier, mode identifier).
        case inputSource(String, sourceId: String, modeId: String)
        ///
        case variable(String, value: String)
    }
}

//public struct Modifiers: Codable {
//    /// Mandatory modifiers that need to be in place for the input to be recognized as such.
//    public let mandatory: Set<Keyboard.Modifier>?
//    /// Modifiers that if they appear, they don't affect on the dectition of the input recognition.
//    public let optional: Set<Keyboard.Modifier>?
//
//    /// Designated initializer that won't allow the arrays to be empty (if so, they will be set to `nil`).
//    ///
//    /// If both arrays are nil or empty, the initializer returns `nil`.
//    public init?(_ mandatory: Set<Keyboard.Modifier>?=nil, optional: Set<Keyboard.Modifier>?=nil) {
//        self.mandatory = mandatory.flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
//        self.optional = optional.flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
//
//        guard case .some(_) = self.mandatory,
//            case .some(_) = self.optional else {
//                return nil
//        }
//    }
//}

