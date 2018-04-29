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
