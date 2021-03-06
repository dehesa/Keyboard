//import Foundation
//
///// A condition that must be satisfied for an input to be recognized.
//public enum Condition: Codable {
//    case frontMostApp(Apps)
//    case devices(Devices)
//    case keyboards(Keyboards)
//    case inputSources(InputSources)
//    case variable(Variable)
//    
//    public init(_ presence: Presence, frontMostApps apps: (bundles: Set<String>?, paths: Set<String>?), _ title: String? = nil) {
//        self = .frontMostApp(Apps(presence, bundleIds: apps.bundles, filePaths: apps.paths, title: title))
//    }
//    
//    public init(_ presence: Presence, deviceIdentifiers: [(vendorId: Int, productId: Int?, title: String?)], _ title: String? = nil) {
//        let ids = deviceIdentifiers.map { Devices.Identifier($2, vendorId: $0, productId: $1) }
//        self = .devices(Devices(presence, Set(ids), title: title))
//    }
//    
//    public init(_ presence: Presence, keyboards types: Set<Keyboards.Kind>, _ title: String? = nil){
//        self = .keyboards(Keyboards(presence, types, title: title))
//    }
//    
//    public init(_ presence: Presence, inputSources: [(language: String?, sourceId: String?, modeId: String?)], _ title: String? = nil) {
//        let sources = inputSources.map({ InputSources.Source(language: $0, identifier: $1, modeId: $2) })
//        self = .inputSources(InputSources(presence, Set(sources), title: title))
//    }
//    
//    public init(_ presence: Presence, variableName name: String, value: Encodable, _ title: String? = nil) {
//        self = .variable(Variable(presence, name, value: value, title: title))
//    }
//
//    /// Whether the type is present or it is absent.
//    /// It could also convey the meaning of entity existence or not.
//    public enum Presence {
//        case are, areNot
//    }
//    
//    /// Condition targeting some Frontmost macOS apps.
//    public struct Apps: Codable {
//        /// A brief title/description about the represented condition.
//        public let title: String?
//        /// Whether the described apps shall be targeted or not.
//        public let presence: Presence
//        /// A set of bundle identifier regular expressions.
//        public let bundleIds: Set<String>?
//        /// A set of application's file path regular expressions.
//        public let filePaths: Set<String>?
//        
//        /// Designated initalizer throwing errors if the parameters were not as expected.
//        public init(_ presence: Presence, bundleIds: Set<String>? = nil, filePaths: Set<String>? = nil, title: String? = nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            self.presence = presence
//            self.bundleIds = bundleIds.flatMap { $0.isEmpty ? nil : bundleIds }
//            self.filePaths = filePaths.flatMap { $0.isEmpty ? nil : filePaths }
//            if self.bundleIds == nil && self.filePaths == nil { fatalError("The condition for \"front most app\" must provide at least a bundle identifier or a file path.") }
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try container.decode(String.self, forKey: .type)
//            let presence = try Condition.presence(of: type, are: CodingKeys.are, areNot: CodingKeys.areNot, codingPath: container.codingPath)
//            let title = try container.decodeIfPresent(String.self, forKey: .title)
//            
//            let bundles = try container.decodeIfPresent(Set<String>.self, forKey: .bundleIds)
//            let paths = try container.decodeIfPresent(Set<String>.self, forKey: .filePaths)
//            self.init(presence, bundleIds: bundles, filePaths: paths, title: title)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            let presence = (self.presence == .are) ? CodingKeys.are : CodingKeys.areNot
//            
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encodeIfPresent(self.title, forKey: .title)
//            try container.encode(presence.stringValue, forKey: .type)
//            try container.encodeIfPresent(self.bundleIds, forKey: .bundleIds)
//            try container.encodeIfPresent(self.filePaths, forKey: .filePaths)
//        }
//        
//        fileprivate enum CodingKeys: String, CodingKey {
//            case type, are = "frontmost_application_if", areNot = "frontmost_application_unless"
//            case title = "description", bundleIds = "bundle_identifiers", filePaths = "file_paths"
//        }
//    }
//    
//    /// Condition targeting a list of connected devices to the host system.
//    public struct Devices: Codable {
//        /// A brief title/description about the represented condition.
//        public let title: String?
//        /// Whether the described connected devices shall be targeted or not.
//        public let presence: Presence
//        /// List of devices matched by this condition.
//        public let identifiers: Set<Identifier>?
//        
//        public init(_ presence: Presence, _ identifiers: Set<Identifier>, title: String? = nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            self.presence = presence
//            guard !identifiers.isEmpty else { fatalError("The condition for \"devices\" must provide at least one match") }
//            self.identifiers = identifiers
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try container.decode(String.self, forKey: .type)
//            let presence = try Condition.presence(of: type, are: CodingKeys.are, areNot: CodingKeys.areNot, codingPath: container.codingPath)
//            let title = try container.decodeIfPresent(String.self, forKey: .title)
//            
//            let identifiers = try container.decode(Set<Identifier>.self, forKey: .identifiers)
//            self.init(presence, identifiers, title: title)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            let presence = (self.presence == .are) ? CodingKeys.are : CodingKeys.areNot
//            
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encodeIfPresent(self.title, forKey: .title)
//            try container.encode(presence.stringValue, forKey: .type)
//            try container.encode(self.identifiers, forKey: .identifiers)
//        }
//        
//        fileprivate enum CodingKeys: String, CodingKey {
//            case type, are = "device_if", areNot = "device_unless"
//            case title = "description", identifiers
//        }
//        
//        public struct Identifier: Hashable, Codable {
//            /// A brief title/description about the represented device.
//            public let title: String?
//            /// The host unique identifier for the device's vendor.
//            public let vendorId: Int
//            /// The host unique identifier for the device.
//            public let productId: Int?
//            
//            /// Designated initializer
//            public init(_ title: String?=nil, vendorId: Int, productId: Int?=nil) {
//                self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//                (self.vendorId, self.productId) = (vendorId, productId)
//            }
//            
//            public var hashValue: Int {
//                return vendorId.hashValue ^ (productId?.hashValue ?? 0)
//            }
//            
//            public static func ==(lhs: Identifier, rhs: Identifier) -> Bool {
//                return (lhs.vendorId == rhs.vendorId) && (lhs.productId == rhs.productId)
//            }
//            
//            private enum CodingKeys: String, CodingKey {
//                case title="description", vendorId="vendor_id", productId="product_id"
//            }
//        }
//    }
//    
//    /// Contion targeting keyboard types
//    public struct Keyboards: Codable {
//        /// A brief title/description about the represented condition.
//        public let title: String?
//        /// Whether the described keyboards shall be targeted or not.
//        public let presence: Presence
//        /// The keyboard types being targeted.
//        public let types: Set<Kind>
//        
//        public init(_ presence: Presence, _ types: Set<Kind>, title: String? = nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            self.presence = presence
//            guard !types.isEmpty else { fatalError("The condition for \"keyboard's types\" must provide at least one keyboard type.") }
//            self.types = types
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try container.decode(String.self, forKey: .type)
//            let presence = try Condition.presence(of: type, are: CodingKeys.are, areNot: CodingKeys.areNot, codingPath: container.codingPath)
//            let title = try container.decodeIfPresent(String.self, forKey: .title)
//            
//            let types = try container.decode(Set<Kind>.self, forKey: .keyboardTypes)
//            self.init(presence, types, title: title)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            let presence = (self.presence == .are) ? CodingKeys.are : CodingKeys.areNot
//            
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encodeIfPresent(self.title, forKey: .title)
//            try container.encode(presence.stringValue, forKey: .type)
//            try container.encode(self.types, forKey: .keyboardTypes)
//        }
//        
//        fileprivate enum CodingKeys: String, CodingKey {
//            case type, are = "keyboard_type_if", areNot = "keyboard_type_unless"
//            case title = "description", keyboardTypes = "keyboard_types"
//        }
//        
//        /// List all possible keyboard types.
//        public enum Kind: String, Codable {
//            case ansi, iso, jis
//        }
//    }
//    
//    /// Condition targeting keyboard input sources.
//    public struct InputSources: Codable {
//        /// A brief title/description about the represented condition.
//        public let title: String?
//        /// Whether the described input source shall be targeted or not.
//        public let presence: Presence
//        /// The input sources being targeted by this condition.
//        public let sources: Set<Source>
//        
//        /// Designated initializer checking that checks whether you are passing at least one source.
//        public init(_ presence: Presence, _ sources: Set<Source>, title: String? = nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            self.presence = presence
//            guard !sources.isEmpty else { fatalError("The condition for \"Input Sources\" must provide at least one input source.") }
//            self.sources = sources
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try container.decode(String.self, forKey: .type)
//            let presence = try Condition.presence(of: type, are: CodingKeys.are, areNot: CodingKeys.areNot, codingPath: container.codingPath)
//            let title = try container.decodeIfPresent(String.self, forKey: .title)
//            
//            let sources = try container.decode(Set<Source>.self, forKey: .inputs)
//            self.init(presence, sources, title: title)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            let presence = (self.presence == .are) ? CodingKeys.are : CodingKeys.areNot
//            
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encodeIfPresent(self.title, forKey: .title)
//            try container.encode(presence.stringValue, forKey: .type)
//            try container.encode(self.sources, forKey: .inputs)
//        }
//        
//        fileprivate enum CodingKeys: String, CodingKey {
//            case type, are = "input_source_if", areNot = "input_source_unless"
//            case title = "description", inputs = "input_sources"
//        }
//        
//        public struct Source: Hashable, Codable {
//            /// The locale identifier for the targeted input source; such as "en", "fr", "en_us", etc.
//            let language: String?
//            /// Reverse DNS identifying the input source.
//            let identifier: String?
//            /// Unknown...
//            let modeId: String?
//            
//            /// Designated initializer
//            public init(language: String?, identifier: String?, modeId: String?) {
//                self.language = language.flatMap { $0.isEmpty ? nil : $0 }
//                self.identifier = identifier.flatMap { $0.isEmpty ? nil : $0 }
//                self.modeId = modeId.flatMap { $0.isEmpty ? nil : $0 }
//                if self.language == nil && self.identifier == nil && self.modeId == nil { fatalError("At least a characteristic of an input source must be given.") }
//            }
//            
//            public var hashValue: Int {
//                return (self.language?.hashValue ?? 0) ^ (self.identifier?.hashValue ?? 0) ^ (self.modeId?.hashValue ?? 0)
//            }
//            
//            public static func ==(lhs: Source, rhs: Source) -> Bool {
//                return (lhs.language == rhs.language) && (lhs.identifier == rhs.identifier) && (lhs.modeId == rhs.modeId)
//            }
//            
//            private enum CodingKeys: String, CodingKey {
//                case language, identifier="input_source_id", modeId="input_mode_id"
//            }
//        }
//    }
//    
//    /// Condition targeting a variable.
//    public struct Variable: Codable {
//        /// A brief title/description about the represented condition.
//        public let title: String?
//        /// Whether the described variable shall be targeted or not.
//        public let presence: Presence
//        /// Variable identifier.
//        public let name: String
//        /// The variable value.
//        public let value: Encodable?
//        
//        /// Designated initializer
//        public init(_ presence: Presence, _ name: String, value: Encodable?, title: String? = nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            self.presence = presence
//            guard !name.isEmpty else { fatalError("The condition for \"Variable\" must provide a name that is not empty.") }
//            self.name = name
//            self.value = value
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            let type = try container.decode(String.self, forKey: .type)
//            let presence = try Condition.presence(of: type, are: CodingKeys.are, areNot: CodingKeys.areNot, codingPath: container.codingPath)
//            let title = try container.decodeIfPresent(String.self, forKey: .title)
//            
//            let name = try container.decode(String.self, forKey: .name)
//            let unknown = try container.decode(JSON.UnknownValue.self, forKey: .value)
//            self.init(presence, name, value: unknown.content, title: title)
//        }
//        
//        public func encode(to encoder: Encoder) throws {
//            let presence = (self.presence == .are) ? CodingKeys.are : CodingKeys.areNot
//            
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            // try container.encodeIfPresent(self.title, forKey: .title)
//            try container.encode(presence.stringValue, forKey: .type)
//            try container.encode(self.name, forKey: .name)
//            try container.encode(JSON.UnknownValue(self.value), forKey: .value)
//        }
//        
//        fileprivate enum CodingKeys: String, CodingKey {
//            case type, are = "variable_if", areNot = "variable_unless"
//            case title = "description", name, value
//        }
//    }
//}
//
//public extension Condition {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let type = try container.decode(String.self, forKey: .type)
//        
//        switch type {
//        case Apps.CodingKeys.are.rawValue: fallthrough
//        case Apps.CodingKeys.areNot.rawValue: self = .frontMostApp(try Apps(from: decoder))
//        case Devices.CodingKeys.are.rawValue: fallthrough
//        case Devices.CodingKeys.areNot.rawValue: self = .devices(try Devices(from: decoder))
//        case Keyboards.CodingKeys.are.rawValue: fallthrough
//        case Keyboards.CodingKeys.areNot.rawValue: self = .keyboards(try Keyboards(from: decoder))
//        case InputSources.CodingKeys.are.rawValue: fallthrough
//        case InputSources.CodingKeys.areNot.rawValue: self = .inputSources(try InputSources(from: decoder))
//        case Variable.CodingKeys.are.rawValue: fallthrough
//        case Variable.CodingKeys.areNot.rawValue: self = .variable(try Variable(from: decoder))
//        default:
//            let errorDescription = "The value \"\(type)\" was not recognized for key: \"\(CodingKeys.type.rawValue)\""
//            throw DecodingError.dataCorruptedError(forKey: .type, in: container.self, debugDescription: errorDescription)
//        }
//    }
//    
//    public func encode(to encoder: Encoder) throws {
//        switch self {
//        case .frontMostApp(let apps):    try apps.encode(to: encoder)
//        case .devices(let devices):      try devices.encode(to: encoder)
//        case .keyboards(let keyboards):  try keyboards.encode(to: encoder)
//        case .inputSources(let sources): try sources.encode(to: encoder)
//        case .variable(let variable):    try variable.encode(to: encoder)
//        }
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case type
//    }
//    
//    fileprivate static func presence(of type: String, are: CodingKey, areNot: CodingKey, codingPath: [CodingKey]) throws -> Presence {
//        switch type {
//        case are.stringValue:    return .are
//        case areNot.stringValue: return .areNot
//        default:
//            let description = "The value \"\(type)\" was not recognized for key: \"\(CodingKeys.type.rawValue)\""
//            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
//            throw DecodingError.dataCorrupted(context)
//        }
//    }
//}
