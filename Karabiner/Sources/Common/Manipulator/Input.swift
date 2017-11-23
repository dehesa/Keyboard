import Foundation

public extension Manipulator {
    /// The input state received.
    ///
    /// This refers to which key code and modifiers are being pressed right now.
    /// The existance (or not) of modifiers, affect the input on the following ways:
    /// - when no modifiers are defined, events are recognized only when the targeted keyCode/button/etc. is pressed, but any modifier is not.
    /// - when there are only mandatory modifiers (but no optionals), events are recognized only when the targeted keyCode/button/etc. is pressed and the specified modifier too. If other modifiers are presed, the event is not recognized.
    /// - when there are only optional modifiers (but no mandatory), events are recognized even when the optinal modifiers are pressed (or not).
    public struct Input: Codable {
        /// The type of input state received from the keyboard.
        public let type: Kind
        /// List of modifiers applied to this input (whether required or optional).
        public let modifiers: (mandatory: Modifiers, optional: Modifiers)
    }
}

public extension Manipulator.Input {
    /// Type of inputs expected from the keyboard.
    ///
    /// Only one can be active at a time.
    public enum Kind {
        /// A key press (with its associated key code).
        case key(Keyboard.Key)
        /// A mouse button.
        case button(Keyboard.Button)
        /// A customer specific key code.
        case custom(String)
        /// Either any key press, or any button click, or any custom key press.
        case any(Manipulator.Input.Kind.`Any`)
        
        /// Convey the idea of any key press, mouse click, or customer key code.
        public enum `Any`: String, Codable {
            case key="key_code", button="pointing_button", custom="consumer_key_code"
        }
    }
    
    /// State of modifiers.
    public enum Modifiers: Codable, ExpressibleByNilLiteral {
        /// No modifier shall be applied.
        case none
        /// The following exact modifiers need to be targeted.
        case modifiers(Set<Keyboard.Modifier>)
        /// Any modifier shall be targeted.
        case any
    }
}

public extension Manipulator.Input {
    /// Designated initializer, where only the type of input is required.
    /// - parameter type: The type of input detected.
    /// - parameter mandatory: Required modifiers for the input to be detected.
    /// - parameter optional:
    public init(_ type: Kind, _ mandatory: Modifiers = .none, optional: Modifiers = .none) {
        self.type = type
        self.modifiers = (mandatory, optional)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type: Kind
        if let keyCode = try container.decodeIfPresent(Keyboard.Key.self, forKey: .keyCode) {
            type = .key(keyCode)
        } else if let button = try container.decodeIfPresent(Keyboard.Button.self, forKey: .button) {
            type = .button(button)
        } else if let customCode = try container.decodeIfPresent(String.self, forKey: .customCode) {
            type = .custom(customCode)
        } else if let either = try container.decodeIfPresent(Kind.`Any`.self, forKey: .any) {
            type = .any(either)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Impossible to figure out what input is expected (e.g. keyCode? pointing button?...)")
            throw DecodingError.dataCorrupted(context)
        }
        
        guard container.contains(.modifiers) else {
            self.init(type, .none, optional: .none); return
        }
        
        let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modifiers)
        let mandatory = try nestedContainer.decodeIfPresent(Modifiers.self, forKey: .mandatory) ?? .none
        let optional = try nestedContainer.decodeIfPresent(Modifiers.self, forKey: .optional) ?? .none
        self.init(type, mandatory, optional: optional)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self.type {
        case .key(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
        case .button(let button): try container.encode(button, forKey: .button)
        case .custom(let custom): try container.encode(custom, forKey: .customCode)
        case .any(let either):    try container.encode(either.rawValue, forKey: .any)
        }
        
        switch self.modifiers {
        case (.none, .none):
            break
        case (let mandatory, .none):
            var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modifiers)
            try nestedContainer.encode(mandatory, forKey: .mandatory)
        case (.none, let optional):
            var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modifiers)
            try nestedContainer.encode(optional, forKey: .optional)
        case (let mandatory, let optional):
            var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .modifiers)
            try nestedContainer.encode(mandatory, forKey: .mandatory)
            try nestedContainer.encode(optional, forKey: .optional)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case button = "pointing_button"
        case customCode = "consumer_key_code"
        case any = "any"
        case modifiers, mandatory, optional
    }
}

public extension Manipulator.Input.Modifiers {
    public init(nilLiteral: ()) {
        self = .none
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let strings = try container.decode(Set<String>.self)
        guard !strings.isEmpty else { self = .none; return }
        guard !strings.contains(CodingKeys.any.rawValue) else { self = .any; return }
        
        let modifiers: [Keyboard.Modifier] = try strings.map {
            guard let result = Keyboard.Modifier(rawValue: $0) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "\"\($0)\" is not a valid modifier.")
            }
            return result
        }
        
        let result = Set<Keyboard.Modifier>(modifiers).filterSimilars()
        guard !result.isEmpty else { self = .none; return }
        self = .modifiers(result)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .modifiers(let array): try container.encode(array)
        case .any: try container.encode(CodingKeys.any.rawValue)
        case .none: try container.encodeNil()
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case any
    }
}
