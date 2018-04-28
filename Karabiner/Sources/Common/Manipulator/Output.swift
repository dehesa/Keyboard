//import Foundation
//
///// The output triggered when the manipulator is matched.
//public struct Output: Hashable, Codable {
//    /// The type of output being triggered.
//    public let type: Kind
//    /// Optional modifiers to be applied with the output.
//    /// It will never be an empty set.
//    public let modifiers: Set<Keyboard.Modifier>?
//    
//    /// Designated initializer, where only the output type is required.
//    /// - parameter type: The type of output being described.
//    /// - parameter modifiers: Modifiers to be applied on the output.
//    public init(_ type: Output.Kind, modifiers: Set<Keyboard.Modifier>? = nil) {
//        self.type = type
//        self.modifiers = modifiers.flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
//    }
//    
//    public init(keyCode code: Keyboard.Key, modifiers: Set<Keyboard.Modifier>? = nil) {
//        self.init(.keyCode(code), modifiers: modifiers)
//    }
//    
//    public init(variable name: String, value: Encodable?, modifiers: Set<Keyboard.Modifier>? = nil){
//        let kind = Variable(name: name, value: value)
//        self.init(.variable(kind), modifiers: modifiers)
//    }
//    
//    public init(button: Mouse.Button, modifiers: Set<Keyboard.Modifier>? = nil){
//        self.init(.button(button), modifiers: modifiers)
//    }
//    
//    public init(consumerKeyCode code: String, modifiers: Set<Keyboard.Modifier>? = nil) {
//        let consumerKeyCode = ConsumerKeyCode(code)
//        self.init(.consumerKeyCode(consumerKeyCode), modifiers: modifiers)
//    }
//    
//    public init(shellCommand command: String, modifiers: Set<Keyboard.Modifier>? = nil) {
//        let shellCommand = ShellCommand(command)
//        self.init(.shellCommand(shellCommand), modifiers: modifiers)
//    }
//    
//    public init(inputSourceLanguage language: String?, sourceId: String?, modeId: String?, modifiers: Set<Keyboard.Modifier>? = nil){
//        let source = InputSource(language: language, identifier: sourceId, modeId: modeId)
//        self.init(.inputSource(source), modifiers: modifiers)
//    }
//
//    /// type of output expected from the virtual keyboard.
//    public enum Kind: Hashable {
//        /// A key press (with its associated key code).
//        case keyCode(Keyboard.Key)
//        /// A mouse button.
//        case button(Mouse.Button)
//        /// A customer specific key code.
//        case consumerKeyCode(ConsumerKeyCode)
//        /// A shell command to be executed on the terminal.
//        case shellCommand(ShellCommand)
//        /// Change keyboard input source (e.g. language, source identifier, mode identifier).
//        /// You can find the current input source identifiers with the **EventViewer** app, under the "Variables" tab.
//        case inputSource(InputSource)
//        /// Lets you set variables.
//        /// You can confirm the current variable state with the **EventViewer** app, under the "Variables" tab.
//        case variable(Variable)
//        
//        public var hashValue: Int {
//            switch self {
//            case .keyCode(let code):         return (1 << 1).hashValue ^ code.hashValue
//            case .button(let button):        return (1 << 2).hashValue ^ button.hashValue
//            case .consumerKeyCode(let code): return (1 << 3).hashValue ^ code.hashValue
//            case .shellCommand(let command): return (1 << 4).hashValue ^ command.hashValue
//            case .inputSource(let source):   return (1 << 5).hashValue ^ source.hashValue
//            case .variable(let variable):    return (1 << 6).hashValue ^ variable.hashValue
//            }
//        }
//        
//        public static func == (lhs: Kind, rhs: Kind) -> Bool {
//            switch (lhs, rhs) {
//            case (.keyCode(let left), .keyCode(let right)): return left == right
//            case (.button(let left), .button(let right)): return left == right
//            case (.consumerKeyCode(let left), .consumerKeyCode(let right)): return left == right
//            case (.shellCommand(let left), .shellCommand(let right)): return left == right
//            case (.inputSource(let left), .inputSource(let right)): return left == right
//            case (.variable(let left), .variable(let right)): return left == right
//            default: return false
//            }
//        }
//    }
//    
//    /// Consumer key code wrapper.
//    /// - note: A structure is defined just to hold a string, so the string can be validated.
//    public struct ConsumerKeyCode: Hashable, Codable {
//        /// A custom consumer key code.
//        public let keyCode: String
//        
//        /// Designated initializer
//        public init(_ keyCode: String) {
//            guard !keyCode.isEmpty else { fatalError("The output's \"Consumer key code\" cannot be empty.") }
//            self.keyCode = keyCode
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.singleValueContainer()
//            self.init(try container.decode(String.self))
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            var container = encoder.singleValueContainer()
//            try container.encode(keyCode)
//        }
//        
//        public var hashValue: Int {
//            return keyCode.hashValue
//        }
//        
//        public static func == (lhs: ConsumerKeyCode, rhs: ConsumerKeyCode) -> Bool {
//            return lhs.keyCode == rhs.keyCode
//        }
//    }
//    
//    /// Shell command holder.
//    /// - note: A structure is defined just to hold a string, so the string can be validated.
//    public struct ShellCommand: Hashable, Codable {
//        /// The shell command to be executed.
//        public let command: String
//        
//        /// Designated initializer
//        public init(_ command: String) {
//            guard !command.isEmpty else { fatalError("The output's \"Shell Command\" cannot be empty.") }
//            self.command = command
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.singleValueContainer()
//            self.init(try container.decode(String.self))
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            var container = encoder.singleValueContainer()
//            try container.encode(command)
//        }
//        
//        public var hashValue: Int {
//            return command.hashValue
//        }
//        
//        public static func == (lhs: ShellCommand, rhs: ShellCommand) -> Bool {
//            return lhs.command == rhs.command
//        }
//    }
//    
//    /// Definition of an input source (with language, DNS reverse identifier, and mode identifier).
//    public struct InputSource: Hashable, Codable {
//        /// The locale identifier for the targeted input source; such as "en", "fr", "en_us", etc.
//        public let language: String?
//        /// Reverse DNS identifying the input source.
//        public let identifier: String?
//        /// Unknown...
//        public let modeId: String?
//        
//        /// Designated initializer.
//        public init(language: String?, identifier: String?, modeId: String?) {
//            self.language = language.flatMap { $0.isEmpty ? nil : $0 }
//            self.identifier = identifier.flatMap { $0.isEmpty ? nil : $0 }
//            self.modeId = modeId.flatMap { $0.isEmpty ? nil : $0 }
//            if self.language == nil && self.identifier == nil && self.modeId == nil { fatalError("The output's \"Input Sources\" must try to match at least one input source.") }
//        }
//        
//        private enum CodingKeys: String, CodingKey {
//            case language, identifier="input_source_id", modeId="input_mode_id"
//        }
//        
//        public var hashValue: Int {
//            return (self.language?.hashValue ?? 0) ^ (self.identifier?.hashValue ?? 0) ^ (self.modeId?.hashValue ?? 0)
//        }
//        
//        public static func ==(lhs: InputSource, rhs: InputSource) -> Bool {
//            return (lhs.language == rhs.language) && (lhs.identifier == rhs.identifier) && (lhs.modeId == rhs.modeId)
//        }
//    }
//    
//    /// Wrapper for a variable name and value.
//    /// - note. Although this protocol conforms to Hashable and Equatable, those definitions are not academically correct. They are "correct enough" to be used on a `Set<Variable>`.
//    public struct Variable: Hashable, Codable {
//        /// The name for the variable (it acts as the identifier).
//        public let name: String
//        /// The variable value/content.
//        public let value: Encodable?
//        
//        /// Designated initializer.
//        public init(name: String, value: Encodable?) {
//            guard !name.isEmpty else { fatalError("The output's \"Variable\" name must not be empty.") }
//            self.name = name
//            self.value = value
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let name = try container.decode(String.self, forKey: .name)
//            let value = try container.decode(JSON.UnknownValue.self, forKey: .value)
//            self.init(name: name, value: value)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(name, forKey: .name)
//            try container.encode(JSON.UnknownValue(value), forKey: .value)
//        }
//        
//        private enum CodingKeys: String, CodingKey {
//            case name, value
//        }
//        
//        public var hashValue: Int {
//            return name.hashValue
//        }
//        
//        public static func == (lhs: Variable, rhs: Variable) -> Bool {
//            return lhs.name == rhs.name
//        }
//    }
//}
//
//public extension Output {
//    public var hashValue: Int {
//        return self.type.hashValue ^ (self.modifiers?.hashValue ?? 0)
//    }
//    
//    public static func == (lhs: Output, rhs: Output) -> Bool {
//        switch (lhs.modifiers, rhs.modifiers) {
//        case (nil, nil): return lhs.type.hashValue == rhs.type.hashValue
//        case (let left?, let right?): return (lhs.type.hashValue == rhs.type.hashValue) && (left == right)
//        default: return false
//        }
//    }
//}
//
//public extension Output {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        let type: Kind
//        if let keyCode = try container.decodeIfPresent(Keyboard.Key.self, forKey: .keyCode) {
//            type = .keyCode(keyCode)
//        } else if let button = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
//            type = .button(button)
//        } else if let consumerKeyCode = try container.decodeIfPresent(ConsumerKeyCode.self, forKey: .customCode) {
//            type = .consumerKeyCode(consumerKeyCode)
//        } else if let command = try container.decodeIfPresent(ShellCommand.self, forKey: .shell) {
//            type = .shellCommand(command)
//        } else if let source = try container.decodeIfPresent(InputSource.self, forKey: .inputSource) {
//            type = .inputSource(source)
//        } else if let variable = try container.decodeIfPresent(Variable.self, forKey: .variable) {
//            type = .variable(variable)
//        } else {
//            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "Impossible to figure out what manipulator's output is being described")
//            throw DecodingError.dataCorrupted(context)
//        }
//        
//        let modifiers = try container.decodeIfPresent(Set<Keyboard.Modifier>.self, forKey: .modifiers)
//                                     .flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
//        self.init(type, modifiers: modifiers)
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(self.modifiers, forKey: .modifiers)
//        
//        switch self.type {
//        case .keyCode(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
//        case .button(let button): try container.encode(button, forKey: .button)
//        case .consumerKeyCode(let code): try container.encode(code, forKey: .customCode)
//        case .shellCommand(let command): try container.encode(command, forKey: .shell)
//        case .inputSource(let source): try container.encode(source, forKey: .inputSource)
//        case .variable(let variable): try container.encode(variable, forKey: .variable)
//        }
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case keyCode = "key_code"
//        case button = "pointing_button"
//        case customCode = "consumer_key_code"
//        case shell = "shell_command"
//        case inputSource = "select_input_source"
//        case variable = "set_variable"
//        case modifiers
//    }
//}
