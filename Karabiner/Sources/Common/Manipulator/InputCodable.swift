import Foundation

extension Input.Key {
    private enum CodingKeys: String, CodingKey {
        case code = "key_code", modifiers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(Keyboard.Key.self, forKey: .code)
        let modifiers = try container.decodeIfPresent(Input.Modifiers.self, forKey: .modifiers)
        self.init(code, modifiers ?? nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        if !modifiers.isEmpty { try container.encode(self.modifiers, forKey: .modifiers) }
    }
}

extension Input.ConsumerKey {
    private enum CodingKeys: String, CodingKey {
        case code = "consumer_key_code", modifiers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(String.self, forKey: .code)
        guard !code.isEmpty else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "The input consumer key code cannot be empty.")
            throw DecodingError.dataCorrupted(context)
        }
        let modifiers = try container.decodeIfPresent(Input.Modifiers.self, forKey: .modifiers)
        self.init(code, modifiers ?? nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        if !modifiers.isEmpty { try container.encode(self.modifiers, forKey: .modifiers) }
    }
}

extension Input.Button {
    private enum CodingKeys: String, CodingKey {
        case code = "pointing_button", modifiers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(Mouse.Button.self, forKey: .code)
        let modifiers = try container.decodeIfPresent(Input.Modifiers.self, forKey: .modifiers)
        self.init(code, modifiers ?? nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.code, forKey: .code)
        if !modifiers.isEmpty { try container.encode(self.modifiers, forKey: .modifiers) }
    }
}

extension Input.`Any` {
    private enum CodingKeys: String, CodingKey {
        case source = "any", modifiers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(Input.`Any`.Source.self, forKey: .source)
        let modifiers = try container.decodeIfPresent(Input.Modifiers.self, forKey: .modifiers)
        self.init(code, modifiers ?? nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.source, forKey: .source)
        if !modifiers.isEmpty { try container.encode(self.modifiers, forKey: .modifiers) }
    }
}

extension Input.Simultaneous {
    private enum CodingKeys: String, CodingKey {
        case inputs = "simultaneous", modifiers, options = "simultaneous_options"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let events = try container.decode(LadenArray<Input.Simultaneous.Event>.self, forKey: .inputs)
        let modifiers = try container.decodeIfPresent(Input.Modifiers.self, forKey: .modifiers)
        let options = try container.decodeIfPresent(Input.Simultaneous.Options.self, forKey: .options)
        self.init(events, modifiers ?? nil, options: options ?? nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.inputs, forKey: .inputs)
        if !self.modifiers.isEmpty { try container.encode(self.modifiers, forKey: .modifiers) }
        if !self.options.isEmpty { try container.encode(self.options, forKey: .options) }
    }
}

extension Input.Simultaneous.Event {
    private enum CodingKeys: String, CodingKey {
        case key = "key_code", consumerKey = "consumer_key_code", button = "pointing_button", any = "any"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let code = try container.decodeIfPresent(Keyboard.Key.self, forKey: .key) {
            self = .key(code: code)
        } else if let code = try container.decodeIfPresent(String.self, forKey: .consumerKey) {
            self = .consumerKey(code: code)
        } else if let code = try container.decodeIfPresent(Mouse.Button.self, forKey: .button) {
            self = .button(code: code)
        } else if let source = try container.decodeIfPresent(Input.`Any`.Source.self, forKey: .any) {
            self = .any(source)
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
        case .any(let source):       try container.encode(source, forKey: .any)
        }
    }
}

extension Input.Modifiers {
    private enum CodingKeys: String, CodingKey {
        case mandatory, optional
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mandatory = try container.decodeIfPresent(Input.Modifiers.List.self, forKey: .mandatory)
        let optional  = try container.decodeIfPresent(Input.Modifiers.List.self, forKey: .optional)
        self.init(mandatory ?? .none, optional: optional ?? .none)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if self.mandatory != .none {
            try container.encode(self.mandatory, forKey: .mandatory)
        }
        if self.optional != .none {
            try container.encode(self.optional, forKey: .optional)
        }
    }
}

extension Input.Modifiers.List {
    private enum CodingKeys: String, CodingKey {
        case any
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
        var container = encoder.unkeyedContainer()
        
        switch self {
        case .none: return
        case .any:  try container.encode(CodingKeys.any.rawValue)
        case .only(let codes):
            for code in codes {
                try container.encode(code)
            }
        }
    }
}
