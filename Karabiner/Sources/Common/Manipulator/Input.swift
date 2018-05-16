import Foundation

/// All Manipulator's input comply to this protocol.
public protocol InputPattern: Codable {
    /// Keyboard modifier keys that must be pressed for the input to be recognized.
    var modifiers: Input.Modifiers { get }
}

/// List of inputs that can be recognized/matched.
public enum Input {
    /// Detection pattern for a single keyboard key press + none/one/many/any modifier keyboard keys presses.
    public struct Key: InputPattern {
        /// Raw keyboard keycode to be matched.
        public let code: Keyboard.Key
        public let modifiers: Input.Modifiers
        /// Designated initializer for keyboard key inputs.
        /// - parameter code: Keyboard keycode that will trigger this input detection pattern.
        /// - parameter modifiers: The combination of keyboard key modifiers that shall be pressed for the input to be recognized. Not defining `modifiers` imply that no modifier keys shall be press for the input to be recognized.
        public init(_ code: Keyboard.Key, _ modifiers: Input.Modifiers = nil) {
            (self.code, self.modifiers) = (code, modifiers)
        }
    }
    /// Detection pattern for a single consumer key press + none/one/many/any modifier keyboard keys presses.
    public struct ConsumerKey: InputPattern {
        /// Raw string matching a consumer key code.
        public let code: String
        public let modifiers: Input.Modifiers
        /// Designated initializer for consumer keyboard key inputs.
        /// - parameter code: Non-empty string representing a consumer keyboard keycode.
        /// - parameter modifiers: The combination of keyboard key modifiers that shall be pressed for the input to be recognized. Not defining `modifiers` imply that no modifier keys shall be press for the input to be recognized.
        public init(_ code: String, _ modifiers: Input.Modifiers = nil) {
            (self.code, self.modifiers) = (code, modifiers)
        }
    }
    /// Detection pattern for a single mouse button press + none/one/many/any modifier keyboard keys presses.
    public struct Button: InputPattern {
        /// Mouse button to be matched.
        public let code: Mouse.Button
        public let modifiers: Input.Modifiers
        /// Designated initializer for mouse buttons inputs.
        /// - parameter code: Mouse button number as identified for the host system.
        /// - parameter modifiers: The combination of keyboard key modifiers that shall be pressed for the input to be recognized. Not defining `modifiers` imply that no modifier keys shall be press for the input to be recognized.
        public init(_ code: Mouse.Button, _ modifiers: Input.Modifiers = nil) {
            (self.code, self.modifiers) = (code, modifiers)
        }
    }
    /// Detection pattern for any input type event (i.e. key press, consumer key press, mouse button press) + none/one/many/any modifier keyboard keys presses.
    ///
    /// For example, a detection pattern where `Any.type = .keyCode` will match any keyboard key being pressed.
    public struct `Any`: InputPattern {
        /// Type of event to be watched by this detection pattern.
        public let source: Input.`Any`.Source
        public let modifiers: Input.Modifiers
        /// Designated initializer for detecting any type of input.
        /// - parameter source: Specify what input event source will be target (i.e. whether key presses, mouse button presses, etc.).
        /// - parameter modifiers: The combination of keyboard key modifiers that shall be pressed for the input to be recognized. Not defining `modifiers` imply that no modifier keys shall be press for the input to be recognized.
        public init(_ source: Input.`Any`.Source, _ modifiers: Input.Modifiers = nil) {
            (self.source, self.modifiers) = (source, modifiers)
        }
    }
    /// Recognizes keys/buttons that are pressed simultaneously (around 50 milliseconds).
    ///
    /// The simultaneous time threshold can be tweaked on the macOS app or programmatically through general settings.
    public struct Simultaneous: InputPattern {
        /// Input events to be recognized simultaneously.
        public let inputs: LadenArray<Input.Simultaneous.Event>
        /// Options for the simultaneous detection, such as input order arrival.
        public let options: Input.Simultaneous.Options
        public let modifiers: Input.Modifiers
        /// Designated initializer for simultaneous inputs.
        /// - parameter simultaneousEvents:
        /// - parameter modifiers: The combination of keyboard key modifiers that shall be pressed for the input to be recognized. Not defining `modifiers` imply that no modifier keys shall be press for the input to be recognized.
        public init(_ simultaneousEvents: LadenArray<Input.Simultaneous.Event>, _ modifiers: Input.Modifiers = nil, options: Input.Simultaneous.Options = nil) {
            (self.inputs, self.modifiers, self.options) = (simultaneousEvents, modifiers, options)
        }
    }
    /// List of modifiers mandatory or optional that are associated with an input.
    public struct Modifiers: Codable, ExpressibleByNilLiteral {
        /// Compulsory modifiers keys that must be pressed for the input to be detected.
        public var mandatory: List = .none
        /// Modifier keys that may be pressed and it won't matter for the input detection.
        public var optional: List = .none
        /// Boolean indicating that no modifiers shall be pressed for the input to be recognized.
        public var isEmpty: Bool {
            return mandatory == .none && optional == .none
        }
        
        public init(nilLiteral: ()) {
            self.init(.none, optional: .none)
        }
        /// Designated initializer specifying the mandataroy and optional keyboard key modifiers.
        public init(_ mandatory: Input.Modifiers.List, optional: Input.Modifiers.List = .none) {
            (self.mandatory, self.optional) = (mandatory, optional)
        }
    }
}

extension Input.`Any` {
    /// List of input event sources that can be recognized.
    public enum Source: String, Codable {
        /// Matches any standard keyboard key (as listed by `Keyboard.Key`).
        case keyCode = "key_code"
        /// Matches any consumer key code.
        case consumerKeyCode = "consumer_key_code"
        /// Matches any mouse button press.
        case button = "pointing_button"
    }
}

extension Input.Simultaneous {
    /// Possible events that can be recognized at the same time.
    public enum Event: Codable {
        /// A given standard keyboard key code.
        case key(code: Keyboard.Key)
        /// A given consumer key code identified by a String.
        case consumerKey(code: String)
        /// A given mouse button code.
        case button(code: Mouse.Button)
        /// Any event source. Be careful with this option.
        case any(Input.`Any`.Source)
    }
    
    /// Options related to the simultaneous key presses, such as key down order.
    public struct Options: Codable, ExpressibleByNilLiteral {
        /// Boolean value indicating whether *key down* detection is interrupted by unrelated events.
        let keyDownDetection: Bool?
        /// *Key down* order detection.
        let keyDownOrder: Order?
        /// *Key up* order detection.
        let keyUpOrder: Order?
        /// Otuputs/Events to be posted when all input events have been released.
        // let keyUpOutput:         // TODO: Add here `Output` type array.
        /// Specify when *key up* outputs are sent.
        // let keyUpOutputPosting:  // TODO: Add the `any` and `all` parameters.
        /// Boolean indicating whether there are any defined options.
        public var isEmpty: Bool {
            return (self.keyDownDetection != nil) || (self.keyDownOrder != nil) || (self.keyUpOrder != nil)
        }
        
        public init(nilLiteral: ()) {
            self.keyDownDetection = nil
            self.keyDownOrder = nil
            self.keyUpOrder = nil
        }
    }
}

extension Input.Simultaneous.Options {
    private enum CodingKeys: String, CodingKey {
        case keyDownDetection = "detect_key_down_uninterruptedly", keyDownOrder = "key_down_order", keyUpOrder = "key_up_order"
    }
    
    /// Simultaneous order of input events.
    public enum Order: String, Codable {
        case insensitive
        case strict
        case strictInverse = "strict_inverse"
    }
}

extension Input.Modifiers {
    /// Modifiers list that must/can be pressed for the input to be identified.
    public enum List: Codable, ExpressibleByNilLiteral, Equatable {
        /// No modifier keys shall be pressed for the detection pattern to be triggered.
        case none
        /// Any modifier keys shall be pressed for the detection pattern to be triggered.
        case any
        /// Only the specified modifier keys shall be pressed for the detection pattern to be triggered.
        case only(LadenSet<Keyboard.Modifier>)
        
        public init(nilLiteral: ()) {
            self = .none
        }
    }
}
