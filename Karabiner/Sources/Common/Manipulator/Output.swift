import Foundation

public extension Manipulator {
    /// The output triggered when the manipulator is matched.
    public struct Output: Codable {
        /// The type of output being triggered.
        public let type: Kind
        /// Optional modifiers to be applied with the output.
        /// It will never be an empty set.
        public let modifiers: Set<Keyboard.Modifier>?
    }
}

public extension Manipulator.Output {
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
        /// You can find the current input source identifiers with the **EventViewer** app, under the "Variables" tab.
        case inputSource(String, sourceId: String, modeId: String)
        /// Lets you set variables.
        /// You can confirm the current variable stete with the **EventViewer** app, under the "Variables" tab.
        case variable(String, value: Encodable?)
    }
}

public extension Manipulator.Output {
    /// Designated initializer, where only the output type is required.
    /// - parameter type: The type of output being described.
    /// - parameter modifiers: Modifiers to be applied on the output.
    public init(_ type: Kind, modifiers: Set<Keyboard.Modifier>? = nil) {
        self.type = type
        self.modifiers = modifiers.flatMap { $0.isEmpty ? nil : $0.filterSimilars() }
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
        } else if let command = try container.decodeIfPresent(String.self, forKey: .shell) {
            type = .shell(command)
        } else if container.contains(.inputSource) {
            let container = try container.nestedContainer(keyedBy: CodingKeys.InputSourcesKeys.self, forKey: .inputSource)
            let language = try container.decode(String.self, forKey: .language)
            let sourceId = try container.decode(String.self, forKey: .sourceId)
            let modeId = try container.decode(String.self, forKey: .modeId)
            type = .inputSource(language, sourceId: sourceId, modeId: modeId)
        } else if container.contains(.variable) {
            let container = try container.nestedContainer(keyedBy: CodingKeys.VariableKeys.self, forKey: .variable)
            let name = try container.decode(String.self, forKey: .name)
            let unknown = try container.decode(JSON.UnknownValue.self, forKey: .value)
            type = .variable(name, value: unknown.content)
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
        
        switch self.type {
        case .key(let keyCode):   try container.encode(keyCode, forKey: .keyCode)
        case .button(let button): try container.encode(button, forKey: .button)
        case .custom(let custom): try container.encode(custom, forKey: .customCode)
        case .shell(let command): try container.encode(command, forKey: .shell)
        case .inputSource(let language, sourceId: let sourceId, modeId: let modeId):
            var container = container.nestedContainer(keyedBy: CodingKeys.InputSourcesKeys.self, forKey: .inputSource)
            try container.encode(language, forKey: .language)
            try container.encode(sourceId, forKey: .sourceId)
            try container.encode(modeId, forKey: .modeId)
        case .variable(let name, value: let value):
            var container = container.nestedContainer(keyedBy: CodingKeys.VariableKeys.self, forKey: .variable)
            try container.encode(name, forKey: .name)
            try container.encode(JSON.UnknownValue(value), forKey: .value)
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
        
        fileprivate enum InputSourcesKeys: String, CodingKey {
            case language, sourceId="input_source_id", modeId="input_mode_id"
        }
        
        fileprivate enum VariableKeys: String, CodingKey {
            case name, value
        }
    }
}
