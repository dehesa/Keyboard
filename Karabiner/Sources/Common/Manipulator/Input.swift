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
        public let modifiers: Modifiers
        
        /// Designated initializer
        public init(_ type: Kind, modifiers: Modifiers) {
            (self.type, self.modifiers) = (type, modifiers)
        }
    }
}

public extension Manipulator.Input {
    /// Type of inputs expected from the keyboard.
    ///
    /// Only one can be active at a time.
    public enum Kind {
        /// A key press (with its associated key code).
        case isKeyCode(Keyboard.Key)
        /// A mouse button.
        case isButton(Mouse.Button)
        /// A customer specific key code.
        case isConsumerKeyCode(ConsumerKeyCode)
        /// Either any key press, or any button click, or any custom key press.
        case isAny(of: Manipulator.Input.Kind.`Any`)
        
        public static func key(code: Keyboard.Key) -> Kind {
            return .isKeyCode(code)
        }
        
        public static func button(_ button: Mouse.Button) -> Kind {
            return .isButton(button)
        }
        
        public static func consumer(keyCode: String) -> Kind? {
            guard let consumerKeyCode = try? ConsumerKeyCode(keyCode) else { return nil }
            return .isConsumerKeyCode(consumerKeyCode)
        }
        
        public static func any(of input: Manipulator.Input.Kind.`Any`) -> Kind {
            return .isAny(of: input)
        }
        
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
        public init(_ keyCode: String) throws {
            guard !keyCode.isEmpty else { throw Error.invalidArguments("The consumer key code cannot be empty.") }
            self.keyCode = keyCode
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            try self.init(try container.decode(String.self))
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
            self.optional = mandatory.qualify()
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

public extension Manipulator.Input {
    /// Lists of errors that can be triggered through an Output statement.
    public enum Error: Swift.Error {
        case invalidArguments(String)
    }
    
    /// Designated initializer, where only the type of input is required.
    /// - parameter type: The type of input detected.
    /// - parameter mandatory: Required modifiers for the input to be detected.
    /// - parameter optional:
    public init(_ type: Kind, _ mandatory: Modifiers.Filter = .none, optional: Modifiers.Filter = .none) {
        self.type = type
        self.modifiers = Modifiers(mandatory: mandatory, optional: optional)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Figure out the type of input.
        let type: Kind
        if let keyCode = try container.decodeIfPresent(Keyboard.Key.self, forKey: .keyCode) {
            type = .isKeyCode(keyCode)
        } else if let button = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
            type = .isButton(button)
        } else if let keyCode = try container.decodeIfPresent(ConsumerKeyCode.self, forKey: .customCode) {
            type = .isConsumerKeyCode(keyCode)
        } else if let either = try container.decodeIfPresent(Kind.`Any`.self, forKey: .any) {
            type = .isAny(of: either)
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
        case .isKeyCode(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
        case .isButton(let button): try container.encode(button, forKey: .button)
        case .isConsumerKeyCode(let custom): try container.encode(custom, forKey: .customCode)
        case .isAny(of: let either):    try container.encode(either.rawValue, forKey: .any)
        }
        
        if !self.isEmpty {
            try container.encode(self.modifiers, forKey: .modifiers)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case button = "pointing_button"
        case customCode = "consumer_key_code"
        case any = "any"
        case modifiers
    }
    
    fileprivate var isEmpty: Bool {
        switch (self.modifiers.mandatory, self.modifiers.optional) {
        case (.none, .none): return true
        default: return false
        }
    }
}
