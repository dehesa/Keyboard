import Foundation

public protocol InputProtocol: Codable {
    var modifiers: Input.Modifiers { get }
}

public enum Input {
    public struct Key: InputProtocol {
        public let code: Keyboard.Key
        public let modifiers: Input.Modifiers
        
        private enum CodingKeys: String, CodingKey {
            case code = "key_code", modifiers
        }
    }
    
    public struct ConsumerKey: InputProtocol {
        public let code: String
        public let modifiers: Input.Modifiers
        
        private enum CodingKeys: String, CodingKey {
            case code = "consumer_key_code", modifiers
        }
    }
    
    public struct Button: InputProtocol {
        public let code: Mouse.Button
        public let modifiers: Input.Modifiers
        
        private enum CodingKeys: String, CodingKey {
            case code = "pointing_button", modifiers
        }
    }
    
    public struct `Any`: InputProtocol {
        public let `type`: Kind
        public let modifiers: Input.Modifiers
        
        public enum Kind: String, Codable {
            case keyCode = "key_code"
            case consumerKeyCode = "consumer_key_code"
            case button = "pointing_button"
        }
        
        private enum CodingKeys: String, CodingKey {
            case `type` = "any", modifiers
        }
    }
}

extension Input {
    public struct Modifiers: Codable {
        public var mandatory: List = .none
        public var optional: List = .none
        
        public enum List: Codable, ExpressibleByNilLiteral {
            case none, any
            case only(Set<Keyboard.Modifier>)
            
            public init(nilLiteral: ()) {
                self = .none
            }
            
            public init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var codes: [String] = []
                
                while !container.isAtEnd {
                    codes.append(try container.decode(String.self))
                }
                
                guard !codes.isEmpty else { self = .none; return }
                guard !codes.contains(where: { $0.lowercased() == CodingKeys.any.rawValue }) else { self = .any; return }
                
                self = .only(Set(try codes.map { (string) -> Keyboard.Modifier in
                    guard let element = Keyboard.Modifier(rawValue: string) else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Modifier keyCode \"\(string)\" couldn't be identified.")
                    }
                    return element
                }))
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
}

//public struct Modifiers: Codable {
//    public var mandatory: [Keyboard.Modifier] = []
//    public var optional: [Keyboard.Modifier] = []
//
//    public var isEmpty: Bool {
//        return mandatory.isEmpty && optional.isEmpty
//    }
//}

//public struct Modifiers: Codable {
//    private let pressed: [Keyboard.Modifier:Bool]
//
//    /// If `true`, the input will only be matched when there is no modifier keys pressed.
//    public var isEmpty: Bool {
//        return !pressed.isEmpty
//    }
//
//    public var mandatory: [Keyboard.Modifier] {
//        return self.pressed.compactMap { return $0.value ? $0.key : nil }
//    }
//
//    public var optional: [Keyboard.Modifier] {
//        return self.pressed.compactMap { return !$0.value ? $0.key : nil }
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.pressed = Dictionary([
//            try container.decodeIfPresent([Keyboard.Modifier].self, forKey: .optional)?.map { ($0, false) },
//            try container.decodeIfPresent([Keyboard.Modifier].self, forKey: .mandatory)?.map { ($0, true) }
//            ].compactMap { $0 }.flatMap { $0 }) { $0 || $1 }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        guard !self.isEmpty else { return }
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        let (mandatory, optional) = (self.mandatory, self.optional)
//        if !mandatory.isEmpty {
//            try container.encode(mandatory, forKey: .mandatory)
//        }
//        if !optional.isEmpty {
//            try container.encode(optional, forKey: .optional)
//        }
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case mandatory, optional
//    }
//}
