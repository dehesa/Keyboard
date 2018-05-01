import Foundation

/// List of inputs that can be recognized/matched.
public enum Input {
    /// Detection pattern for a single keyboard key press + none/one/many/any modifier keyboard keys presses.
    public struct Key: InputDetectionPattern {
        /// Raw keyboard keycode to be matched.
        public let code: Keyboard.Key
        public let modifiers: Input.Modifiers
    }
    /// Detection pattern for a single consumer key press + none/one/many/any modifier keyboard keys presses.
    public struct ConsumerKey: InputDetectionPattern {
        /// Raw string matching a consumer key code.
        public let code: String
        public let modifiers: Input.Modifiers
    }
    /// Detection pattern for a single mouse button press + none/one/many/any modifier keyboard keys presses.
    public struct Button: InputDetectionPattern {
        /// Mouse button to be matched.
        public let code: Mouse.Button
        public let modifiers: Input.Modifiers
    }
    /// Detection pattern for any input type event (i.e. key press, consumer key press, mouse button press) + none/one/many/any modifier keyboard keys presses.
    ///
    /// For example, a detection pattern where `Any.type = .keyCode` will match any keyboard key being pressed.
    public struct `Any`: InputDetectionPattern {
        /// Type of event to be watched by this detection pattern.
        public let type: Input.`Any`.Kind
        public let modifiers: Input.Modifiers
    }
    
    /// Recognizes keys/buttons that are pressed simultaneously (around 50 milliseconds).
    ///
    /// The simultaneous time threshold can be tweaked on the macOS app or programmatically through general settings.
    public struct Simultaneous: InputDetectionPattern {
        /// Input events to be recognized simultaneously.
        public let inputs: LadenArray<Input.Simultaneous.Event>
        public let modifiers: Input.Modifiers
        /// Options for the simultaneous detection, such as input order arrival.
        public let options: Input.Simultaneous.Options
    }
}

public protocol InputDetectionPattern: Codable {
    /// Keyboard modifier keys that must be pressed for the input to be recognized.
    var modifiers: Input.Modifiers { get }
}

extension Input.Key {
    private enum CodingKeys: String, CodingKey {
        case code = "key_code", modifiers
    }
}

extension Input.ConsumerKey {
    private enum CodingKeys: String, CodingKey {
        case code = "consumer_key_code", modifiers
    }
}

extension Input.Button {
    private enum CodingKeys: String, CodingKey {
        case code = "pointing_button", modifiers
    }
}

extension Input.`Any` {
    /// List of input event types that can be recognized.
    public enum Kind: String, Codable {
        case keyCode = "key_code"
        case consumerKeyCode = "consumer_key_code"
        case button = "pointing_button"
    }
    
    private enum CodingKeys: String, CodingKey {
        case type = "any", modifiers
    }
}

extension Input.Simultaneous {
    private enum CodingKeys: String, CodingKey {
        case inputs = "simultaneous", modifiers, options = "simultaneous_options"
    }
    
    public enum Event: Codable {
        case key(code: Keyboard.Key)
        case consumerKey(code: String)
        case button(code: Mouse.Button)
        case any(Input.`Any`.Kind)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let code = try container.decodeIfPresent(Keyboard.Key.self, forKey: .key) {
                self = .key(code: code)
            } else if let code = try container.decodeIfPresent(String.self, forKey: .consumerKey) {
                self = .consumerKey(code: code)
            } else if let code = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
                self = .button(code: code)
            } else if let type = try container.decodeIfPresent(Input.`Any`.Kind.self, forKey: .any) {
                self = .any(type)
            } else {
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Event key/value for simultaneous input could not be identifier")
                throw DecodingError.dataCorrupted(context)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .key(let code):         try container.encode(code, forKey: .key)
            case .consumerKey(let code): try container.encode(code, forKey: .consumerKey)
            case .button(let code):      try container.encode(code, forKey: .button)
            case .any(let type):         try container.encode(type, forKey: .any)
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case key = "key_code", consumerKey = "consumer_key_code", button = "pointing_button", any = "any"
        }
    }
    
    public struct Options: Codable {
        /// Boolean value indicating whether *key down* detection is interrupted by unrelated events.
        let keyDownDetection: Bool?
        /// *Key down* order detection.
        let keyDownOrder: Order?
        /// *Key up* order detection.
        let keyUpOrder: Order?
        /// Otuputs/Events to be posted when all input events have been released.
        // let keyUpOutput: // TODO: Add here `Output` type array.
        /// Specify when *key up* outputs are sent.
        // let keyUpOutputPosting: // TODO: Add the `any` and `all` parameters.
        
        public var isEmpty: Bool {
            return (self.keyDownDetection != nil) || (self.keyDownOrder != nil) || (self.keyUpOrder != nil)
        }
        
        private enum CodingKeys: String, CodingKey {
            case keyDownDetection = "detect_key_down_uninterruptedly", keyDownOrder = "key_down_order", keyUpOrder = "key_up_order"
        }
        
        public enum Order: String, Codable {
            case insensitive
            case strict
            case strictInverse = "strict_inverse"
        }
    }
}

extension Input {
    public struct Modifiers: Codable {
        public var mandatory: List = .none
        public var optional: List = .none
        
        public var isEmpty: Bool {
            return mandatory == .none && optional == .none
        }
    }
}

extension Input.Modifiers {
    public enum List: Codable, ExpressibleByNilLiteral, Equatable {
        case none, any
        case only(LadenSet<Keyboard.Modifier>)
        
        public init(nilLiteral: ()) {
            self = .none
        }
        
        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            var codes = Set<String>()
            
            while !container.isAtEnd {
                codes.insert(try container.decode(String.self))
            }
            
            guard !codes.isEmpty else { self = .none; return }
            guard !codes.contains(where: { $0.lowercased() == CodingKeys.any.rawValue }) else { self = .any; return }
            
            let modifiers = try codes.map { (string) -> Keyboard.Modifier in
                guard let element = Keyboard.Modifier(rawValue: string) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Modifier keyCode \"\(string)\" couldn't be identified.")
                }
                return element
            }
            
            if let result = LadenSet<Keyboard.Modifier>(modifiers) {
                self = .only(result)
            } else {
                self = .none
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .none:
                return
            case .any:
                var container = encoder.unkeyedContainer()
                try container.encode(CodingKeys.any.rawValue)
            case .only(let codes):
                guard !codes.isEmpty else { return }
                
                var container = encoder.unkeyedContainer()
                for code in codes {
                    try container.encode(code)
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case any
        }
    }
}
