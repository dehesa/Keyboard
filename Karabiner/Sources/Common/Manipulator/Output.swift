import Foundation

public extension Manipulator {
    /// The output triggered when the manipulator is matched.
    public struct Output: Hashable, Codable {
        /// The type of output being triggered.
        public let type: Kind
        /// Optional modifiers to be applied with the output.
        /// It will never be an empty set.
        public let modifiers: Set<Keyboard.Modifier>?
        
        /// Designated initializer, where only the output type is required.
        /// - parameter type: The type of output being described.
        /// - parameter modifiers: Modifiers to be applied on the output.
        public init(_ type: Kind, modifiers: Set<Keyboard.Modifier>? = nil) {
            self.type = type
            self.modifiers = modifiers.flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
        }
        
        public var hashValue: Int {
            return self.type.hashValue ^ (self.modifiers?.hashValue ?? 0)
        }
        
        public static func == (lhs: Output, rhs: Output) -> Bool {
            switch (lhs.modifiers, rhs.modifiers) {
            case (nil, nil): return lhs.type.hashValue == rhs.type.hashValue
            case (let left?, let right?): return (lhs.type.hashValue == rhs.type.hashValue) && (left == right)
            default: return false
            }
        }

    }
}

public extension Manipulator.Output {
    /// type of output expected from the virtual keyboard.
    public enum Kind: Hashable {
        /// A key press (with its associated key code).
        case setKeyCode(Keyboard.Key)
        /// A mouse button.
        case setButton(Mouse.Button)
        /// A customer specific key code.
        case setConsumerKeyCode(ConsumerKeyCode)
        /// A shell command to be executed on the terminal.
        case setShellCommand(ShellCommand)
        /// Change keyboard input source (e.g. language, source identifier, mode identifier).
        /// You can find the current input source identifiers with the **EventViewer** app, under the "Variables" tab.
        case setInputSource(InputSource)
        /// Lets you set variables.
        /// You can confirm the current variable state with the **EventViewer** app, under the "Variables" tab.
        case setVariable(Variable)
        
        public static func key(code: Keyboard.Key) -> Kind {
            return .setKeyCode(code)
        }
        
        public static func button(_ button: Mouse.Button) -> Kind {
            return .setButton(button)
        }
        
        public static func consumer(keyCode: String) -> Kind? {
            guard let consumerKeyCode = try? ConsumerKeyCode(keyCode) else { return nil }
            return .setConsumerKeyCode(consumerKeyCode)
        }
        
        public static func shell(command: String) -> Kind? {
            guard let shellCommand = try? ShellCommand(command) else { return nil }
            return .setShellCommand(shellCommand)
        }
        
        public static func inputSource(language: String?, sourceId: String?, modeId: String?) -> Kind? {
            guard let source = try? InputSource(language: language, identifier: sourceId, modeId: modeId) else { return nil }
            return .setInputSource(source)
        }
        
        public static func variable(name: String, value: Encodable?) -> Kind? {
            guard let variable = try? Variable(name: name, value: value) else { return nil }
            return .setVariable(variable)
        }
        
        public var hashValue: Int {
            switch self {
            case .setKeyCode(let code):         return (1 << 1).hashValue ^ code.hashValue
            case .setButton(let button):        return (1 << 2).hashValue ^ button.hashValue
            case .setConsumerKeyCode(let code): return (1 << 3).hashValue ^ code.hashValue
            case .setShellCommand(let command): return (1 << 4).hashValue ^ command.hashValue
            case .setInputSource(let source):   return (1 << 5).hashValue ^ source.hashValue
            case .setVariable(let variable):    return (1 << 6).hashValue ^ variable.hashValue
            }
        }
        
        public static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case (.setKeyCode(let left), .setKeyCode(let right)): return left == right
            case (.setButton(let left), .setButton(let right)): return left == right
            case (.setConsumerKeyCode(let left), .setConsumerKeyCode(let right)): return left == right
            case (.setShellCommand(let left), .setShellCommand(let right)): return left == right
            case (.setInputSource(let left), .setInputSource(let right)): return left == right
            case (.setVariable(let left), .setVariable(let right)): return left == right
            default: return false
            }
        }
    }
    
    /// Consumer key code wrapper.
    /// - note: A structure is defined just to hold a string, so the string can be validated.
    public struct ConsumerKeyCode: Hashable, Codable {
        /// A custom consumer key code.
        public let keyCode: String
        
        /// Designated initializer
        public init(_ keyCode: String) throws {
            guard !keyCode.isEmpty else { throw Manipulator.Error.invalidArguments("The consumer key code cannot be empty.") }
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
        
        public var hashValue: Int {
            return keyCode.hashValue
        }
        
        public static func == (lhs: ConsumerKeyCode, rhs: ConsumerKeyCode) -> Bool {
            return lhs.keyCode == rhs.keyCode
        }
    }
    
    /// Shell command holder.
    /// - note: A structure is defined just to hold a string, so the string can be validated.
    public struct ShellCommand: Hashable, Codable {
        /// The shell command to be executed.
        public let command: String
        
        /// Designated initializer
        public init(_ command: String) throws {
            guard !command.isEmpty else { throw Manipulator.Error.invalidArguments("The shell command cannot be empty.") }
            self.command = command
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            try self.init(try container.decode(String.self))
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(command)
        }
        
        public var hashValue: Int {
            return command.hashValue
        }
        
        public static func == (lhs: ShellCommand, rhs: ShellCommand) -> Bool {
            return lhs.command == rhs.command
        }
    }
    
    /// Definition of an input source (with language, DNS reverse identifier, and mode identifier).
    public struct InputSource: Hashable, Codable {
        /// The locale identifier for the targeted input source; such as "en", "fr", "en_us", etc.
        public let language: String?
        /// Reverse DNS identifying the input source.
        public let identifier: String?
        /// Unknown...
        public let modeId: String?
        
        /// Designated initializer.
        public init(language: String?, identifier: String?, modeId: String?) throws {
            self.language = language.flatMap { $0.isEmpty ? nil : $0 }
            self.identifier = identifier.flatMap { $0.isEmpty ? nil : $0 }
            self.modeId = modeId.flatMap { $0.isEmpty ? nil : $0 }
            if self.language == nil && self.identifier == nil && self.modeId == nil { throw Manipulator.Error.invalidArguments("At least a characteristic of an input source must be given.") }
        }
        
        private enum CodingKeys: String, CodingKey {
            case language, identifier="input_source_id", modeId="input_mode_id"
        }
        
        public var hashValue: Int {
            return (self.language?.hashValue ?? 0) ^ (self.identifier?.hashValue ?? 0) ^ (self.modeId?.hashValue ?? 0)
        }
        
        public static func ==(lhs: InputSource, rhs: InputSource) -> Bool {
            return (lhs.language == rhs.language) && (lhs.identifier == rhs.identifier) && (lhs.modeId == rhs.modeId)
        }
    }
    
    /// Wrapper for a variable name and value.
    /// - note. Although this protocol conforms to Hashable and Equatable, those definitions are not academically correct. They are "correct enough" to be used on a `Set<Variable>`.
    public struct Variable: Hashable, Codable {
        /// The name for the variable (it acts as the identifier).
        public let name: String
        /// The variable value/content.
        public let value: Encodable?
        
        /// Designated initializer.
        public init(name: String, value: Encodable?) throws {
            guard !name.isEmpty else { throw Manipulator.Error.invalidArguments("The variable name must have at least one character.") }
            self.name = name
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            let value = try container.decode(JSON.UnknownValue.self, forKey: .value)
            try self.init(name: name, value: value)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(JSON.UnknownValue(value), forKey: .value)
        }
        
        private enum CodingKeys: String, CodingKey {
            case name, value
        }
        
        public var hashValue: Int {
            return name.hashValue
        }
        
        public static func == (lhs: Variable, rhs: Variable) -> Bool {
            return lhs.name == rhs.name
        }
    }
}

public extension Manipulator.Output {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type: Kind
        if let keyCode = try container.decodeIfPresent(Keyboard.Key.self, forKey: .keyCode) {
            type = .setKeyCode(keyCode)
        } else if let button = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
            type = .setButton(button)
        } else if let consumerKeyCode = try container.decodeIfPresent(ConsumerKeyCode.self, forKey: .customCode) {
            type = .setConsumerKeyCode(consumerKeyCode)
        } else if let command = try container.decodeIfPresent(ShellCommand.self, forKey: .shell) {
            type = .setShellCommand(command)
        } else if let source = try container.decodeIfPresent(InputSource.self, forKey: .inputSource) {
            type = .setInputSource(source)
        } else if let variable = try container.decodeIfPresent(Variable.self, forKey: .variable) {
            type = .setVariable(variable)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Impossible to figure out what manipulator's output is being described")
            throw DecodingError.dataCorrupted(context)
        }
        
        let modifiers = try container.decodeIfPresent(Set<Keyboard.Modifier>.self, forKey: .modifiers)
                                     .flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
        self.init(type, modifiers: modifiers)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.modifiers, forKey: .modifiers)
        
        switch self.type {
        case .setKeyCode(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
        case .setButton(let button): try container.encode(button, forKey: .button)
        case .setConsumerKeyCode(let code): try container.encode(code, forKey: .customCode)
        case .setShellCommand(let command): try container.encode(command, forKey: .shell)
        case .setInputSource(let source): try container.encode(source, forKey: .inputSource)
        case .setVariable(let variable): try container.encode(variable, forKey: .variable)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case keyCode = "key_code"
        case button = "pointing_button"
        case customCode = "consumer_key_code"
        case shell = "shell_command"
        case inputSource = "select_input_source"
        case variable = "set_variable"
        case modifiers
    }
}
