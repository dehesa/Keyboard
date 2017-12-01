import Foundation

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
    public let modifiers: Modifiers
    
    /// Designated initializer
    public init(_ type: Kind, modifiers: Modifiers) {
        (self.type, self.modifiers) = (type, modifiers)
    }
    
    /// Designated initializer, where only the type of input is required.
    /// - parameter type: The type of input detected.
    /// - parameter mandatory: Required modifiers for the input to be detected.
    /// - parameter optional:
    public init(_ type: Kind, _ mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.type = type
        self.modifiers = Modifiers(mandatory: mandatory, optional: optional)
    }
    
    public init(keyCode code: Keyboard.Key, mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.init(.keyCode(code), mandatory, optional: optional)
    }
    
    public init(button: Mouse.Button, mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.init(.button(button), mandatory, optional: optional)
    }
    
    public init(consumerKeyCode code: String, _ mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.init(.consumerKeyCode(ConsumerKeyCode(code)), mandatory, optional: optional)
    }
    
    public init(any input: Input.Kind.`Any`, _ mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.init(.any(input), mandatory, optional: optional)
    }
    
    /// Type of inputs expected from the keyboard.
    ///
    /// Only one can be active at a time.
    public enum Kind {
        /// A key press (with its associated key code).
        case keyCode(Keyboard.Key)
        /// A mouse button.
        case button(Mouse.Button)
        /// A customer specific key code.
        case consumerKeyCode(ConsumerKeyCode)
        /// Either any key press, or any button click, or any custom key press.
        case any(Input.Kind.`Any`)
        
        /// Convey the idea of any key press, mouse click, or customer key code.
        public enum `Any`: String, Codable {
            case key="key_code", button="pointing_button", custom="consumer_key_code"
        }
    }
    
    /// Consumer key code wrapper.
    /// - note: A structure is defined just to hold a string, so the string can be validated.
    public struct ConsumerKeyCode: Codable {
        /// A custom consumer key code.
        public let keyCode: String
        
        /// Designated initializer
        public init(_ keyCode: String) {
            guard !keyCode.isEmpty else { fatalError("The input's consumer key code cannot be empty.") }
            self.keyCode = keyCode
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.init(try container.decode(String.self))
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(keyCode)
        }
    }
    
    /// State of modifiers.
    public struct Modifiers: Codable {
        /// The modifiers that must be there for the input to match.
        public let mandatory: Filter
        /// The modifiers that can be there and it will not affect the input match.
        public let optional: Filter
        
        public init(mandatory: Filter = .none, optional: Filter = .none) {
            self.mandatory = mandatory.qualify()
            self.optional = optional.qualify()
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.mandatory = try container.decodeIfPresent(Filter.self, forKey: .mandatory) ?? .none
            self.optional = try container.decodeIfPresent(Filter.self, forKey: .optional) ?? .none
        }
        
        public func encode(to encoder: Encoder) throws {
            if case .none = self.mandatory, case .none = self.optional {
                var container = encoder.singleValueContainer()
                return try container.encodeNil()
            }
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            if self.mandatory != .none {
                try container.encode(self.mandatory, forKey: .mandatory)
            }
            
            if self.optional != .none {
                try container.encode(self.optional, forKey: .optional)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case mandatory, optional
        }
        
        /// It lets the user select the quantity of modifiers: whether none, any, or a specific amount of them.
        public enum Filter: Codable, Equatable, ExpressibleByNilLiteral {
            /// No modifier shall be applied.
            case none
            /// The following exact modifiers need to be targeted.
            case modifiers(Set<Keyboard.Modifier>)
            /// Any modifier shall be targeted.
            case any
            
            public init(nilLiteral: ()) {
                self = .none
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let names = try container.decode([String].self)
                
                guard !names.contains(CodingKeys.any.rawValue) else {
                    self = .any; return
                }
                
                let modifiers = try container.decode(Set<Keyboard.Modifier>.self)
                self = (modifiers.isEmpty) ? .none : .modifiers(modifiers)
            }
            
            public func encode(to encoder: Encoder) throws {
                switch self {
                case .none:
                    var container = encoder.singleValueContainer()
                    try container.encodeNil()
                case .any:
                    var container = encoder.unkeyedContainer()
                    try container.encode(CodingKeys.any.rawValue)
                case .modifiers(let modifiers):
                    var container = encoder.unkeyedContainer()
                    try container.encode(contentsOf: modifiers)
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case any
            }
            
            /// Checks whether the `.modifiers(set)` set is empty and if so, returns `.none`.
            fileprivate func qualify() -> Filter {
                guard case .modifiers(let modifiers) = self, modifiers.isEmpty else { return self }
                return .none
            }
            
            public static func == (lhs: Filter, rhs: Filter) -> Bool {
                switch (lhs, rhs) {
                case (.none, .none), (.any, .any): return true
                case (.modifiers(let left), .modifiers(let right)): return left == right
                default: return false
                }
            }
        }
    }
}

public extension Input {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Figure out the type of input.
        let type: Kind
        if let keyCode = try container.decodeIfPresent(Keyboard.Key.self, forKey: .keyCode) {
            type = .keyCode(keyCode)
        } else if let button = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
            type = .button(button)
        } else if let keyCode = try container.decodeIfPresent(ConsumerKeyCode.self, forKey: .customCode) {
            type = .consumerKeyCode(keyCode)
        } else if let either = try container.decodeIfPresent(Kind.`Any`.self, forKey: .any) {
            type = .any(either)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Impossible to figure out what input is expected (e.g. keyCode? pointing button?...)")
            throw DecodingError.dataCorrupted(context)
        }
        
        let modifiers = try container.decodeIfPresent(Modifiers.self, forKey: .modifiers)
        self.init(type, modifiers: modifiers ?? Modifiers())
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self.type {
        case .keyCode(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
        case .button(let button): try container.encode(button, forKey: .button)
        case .consumerKeyCode(let custom): try container.encode(custom, forKey: .customCode)
        case .any(let either):    try container.encode(either.rawValue, forKey: .any)
        }
        
        if case .none = self.modifiers.mandatory, case .none = self.modifiers.optional { return }
        try container.encode(self.modifiers, forKey: .modifiers)
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case button = "pointing_button"
        case customCode = "consumer_key_code"
        case any = "any"
        case modifiers
    }
}
