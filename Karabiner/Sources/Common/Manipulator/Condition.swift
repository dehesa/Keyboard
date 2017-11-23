import Foundation

public extension Manipulator {
    /// A condition that must be satisfied for an input to be recognized.
    public enum Condition: Codable {
        case frontMostApps(Apps)
//        case device(Presence, Set<Device>, String?)
//        case keyboard(Presence, Set<KeyboardType>, String?)
//        case inputSource(Presence, InputSource, String?)
//        case variable(Presence, String, value: Encodable?, String?)
        
        public static func apps(_ presence: Presence, bundles: Set<String>? = nil, paths: Set<String>? = nil, title: String? = nil) -> Condition? {
            guard let app = try? Apps(presence, bundleIds: bundles, filePaths: paths, title: title) else { return nil }
            return .frontMostApps(app)
        }
    }
}

public extension Manipulator.Condition {
    /// Whether the type is present or it is absent.
    /// It could also convey the meaning of entity existence or not.
    public enum Presence {
        case `is`, isNot
    }
    
    /// Identify macOS applications.
    public struct Apps: Codable {
        /// A brief title/description about the represented apps.
        public let title: String?
        /// Whether the described apps shall be targeted or not.
        public let presence: Presence
        /// A set of bundle identifier regular expressions.
        public let bundleIds: Set<String>?
        /// A set of application's file path regular expressions.
        public let filePaths: Set<String>?
        
        public init(_ presence: Presence, bundleIds: Set<String>? = nil, filePaths: Set<String>? = nil, title: String? = nil) throws {
            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
            self.presence = presence
            self.bundleIds = bundleIds.flatMap { $0.isEmpty ? nil : bundleIds }
            self.filePaths = filePaths.flatMap { $0.isEmpty ? nil : filePaths }
            if self.bundleIds == nil && self.filePaths == nil { throw Error.invalidArguments }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let presence = try Manipulator.Condition.presence(of: type, is: CodingKeys.is, isNot: CodingKeys.isNot, codingPath: container.codingPath)
            let bundles = try container.decode(Set<String>.self, forKey: .bundleIds)
            let paths = try container.decode(Set<String>.self, forKey: .filePaths)
            let title = try container.decode(String.self, forKey: .title)
            try self.init(presence, bundleIds: bundles, filePaths: paths, title: title)
        }
        
        public func encode(to encoder: Encoder) throws {
            let presence = (self.presence == .is) ? CodingKeys.is : CodingKeys.isNot
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(presence.stringValue, forKey: .type)
            try container.encodeIfPresent(bundleIds, forKey: .bundleIds)
            try container.encodeIfPresent(filePaths, forKey: .filePaths)
        }
        
        public enum Error: Swift.Error {
            case invalidArguments
        }
        
        fileprivate enum CodingKeys: String, CodingKey {
            case type, `is` = "frontmost_application_if", isNot = "frontmost_application_unless"
            case title = "description", bundleIds = "bundle_identifiers", filePaths = "file_paths"
        }
    }
}

public extension Manipulator.Condition {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case Apps.CodingKeys.is.rawValue: fallthrough
        case Apps.CodingKeys.isNot.rawValue: self = .frontMostApps(try Apps(from: decoder))
        default:
            let errorDescription = "The value \"\(type)\" was not recognized for key: \"\(CodingKeys.type.rawValue)\""
            throw DecodingError.dataCorruptedError(forKey: .type, in: container.self, debugDescription: errorDescription)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .frontMostApps(let apps):
            try apps.encode(to: encoder)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        
//        private enum TypeKeys: String {
//            case appIs = "frontmost_application_if", appNot = "frontmost_application_unless"
//            case deviceIs = "device_if", deviceNot = "device_unless"
//            case keyboardIs = "keyboard_type_if", keyboardNot = "keyboard_type_unless"
//            case inputSourceIs = "input_source_if", inputSourceNot = "input_source_unless"
//            case variableIs = "variable_if", variableNot = "variable_unless"
//        }
    }
    
    fileprivate static func presence(of type: String, `is`: CodingKey, isNot: CodingKey, codingPath: [CodingKey]) throws -> Presence {
        switch type {
        case `is`.stringValue:  return .is
        case isNot.stringValue: return .isNot
        default:
            let description = "The value \"\(type)\" was not recognized for key: \"\(CodingKeys.type.rawValue)\""
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
            throw DecodingError.dataCorrupted(context)
        }
    }
}

//    /// Represents a physical device connected to the host.
//    public struct Device: Hashable, Codable {
//        /// A brief title/description about the represented device.
//        public let title: String?
//        /// The host unique identifier for the device's vendor.
//        public let vendorId: Int
//        /// The host unique identifier for the device.
//        public let productId: Int?
//
//        /// Designated initializer
//        public init(_ title: String?=nil, vendorId: Int, productId: Int?=nil) {
//            self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//            (self.vendorId, self.productId) = (vendorId, productId)
//        }
//
//        public var hashValue: Int {
//            guard let hash = productId?.hashValue else { return vendorId.hashValue }
//            return vendorId.hashValue ^ hash
//        }
//
//        public static func ==(lhs: Device, rhs: Device) -> Bool {
//            guard lhs.vendorId == rhs.vendorId else { return false }
//            switch (lhs.productId, rhs.productId) {
//            case (.none, .none): return true
//            case (let leftId?, let rightId?): return leftId == rightId
//            default: return false
//            }
//        }
//
//        private enum CodingKeys: String, CodingKey {
//            case title="description", vendorId="vendor_id", productId="product_id"
//        }
//    }
//
//    /// List all possible keyboard types.
//    public enum KeyboardType: String, Codable {
//        case ansi, iso, jis
//    }
//
//    /// The input sources
//    public struct InputSource {
//        ///
//
//    }
//}
//
//public extension Manipulator .Condition {
//    /// List of errors that can be raised by the `App` structure.
//    public enum Error: Swift.Error {
//        case noArguments
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let title = (try container.decodeIfPresent(String.self, forKey: .title)).flatMap { $0.isEmpty ? nil : $0 }
//
//        typealias T = CodingKeys.Types
//        let type = try container.decode(String.self, forKey: .type)
//
//        switch type {
//        case T.appIs.rawValue:
//            self = .frontMostApp(.is, try Apps(decoding: container), title)
//        case T.appNot.rawValue:
//            self = .frontMostApp(.isNot, try Apps(decoding: container), title)
//        case T.deviceIs.rawValue:
//            let devices = try container.decode(Set<Device>.self, forKey: .deviceIdentifiers)
//            self = .device(.is, devices, title);
//        case T.deviceNot.rawValue:
//            let devices = try container.decode(Set<Device>.self, forKey: .deviceIdentifiers)
//            self = .device(.isNot, devices, title);
//        case T.keyboardIs.rawValue:
//            let types = try container.decode(Set<KeyboardType>.self, forKey: .keyboardTypes)
//            self = .keyboard(.is, types, title)
//        case T.keyboardNot.rawValue:
//            let types = try container.decode(Set<KeyboardType>.self, forKey: .keyboardTypes)
//            self = .keyboard(.isNot, types, title)
//        case T.inputSourceIs.rawValue: self = ;
//        case T.inputSourceNot.rawValue: self = ;
//        case T.variableIs.rawValue: self = ;
//        case T.variableNot.rawValue: self = ;
//        default:
//            let errorDescription = "The value \"\(type)\" was not recognized for key: \"\(CodingKeys.type.rawValue)\""
//            throw DecodingError.dataCorruptedError(forKey: .type, in: container.self, debugDescription: errorDescription)
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//
//        typealias T = CodingKeys.Types
//
//        switch self {
//        case .frontMostApp(let presence, let app, let title):
//            let type = (presence == .is) ? T.appIs : T.appNot
//            try container.encode(type.rawValue, forKey: .type)
//            try container.encodeIfPresent(title, forKey: .title)
//            try container.encodeIfPresent(app.bundleIds, forKey: .appBundleIds)
//            try container.encodeIfPresent(app.filePaths, forKey: .appFilePaths)
//        case .device(let presence, let devices, let title):
//            let type = (presence == .is) ? T.deviceIs : T.deviceNot
//            try container.encode(type.rawValue, forKey: .type)
//            try container.encodeIfPresent(title, forKey: .title)
//            try container.encode(devices, forKey: .deviceIdentifiers)
//        case .keyboard(let presence, let types, let title):
//            let type = (presence == .is) ? T.keyboardIs : T.keyboardNot
//            try container.encode(type.rawValue, forKey: .type)
//            try container.encodeIfPresent(title, forKey: .title)
//            try container.encode(types, forKey: .keyboardTypes)
//        case .inputSource(let presence, let inputSource, let title):
//            let type = (presence == .is) ? T.inputSourceIs : T.inputSourceNot
//            try container.encode(type.rawValue, forKey: .type)
//            try container.encodeIfPresent(title, forKey: .title)
//
//        case .variable(let presence, let name, value: let value, let title):
//            let type = (presence == .is) ? T.variableIs : T.variableNot
//            try container.encode(type.rawValue, forKey: .type)
//            try container.encodeIfPresent(title, forKey: .title)
//
//        }
//    }
//
//    fileprivate enum CodingKeys: String, CodingKey {
//        case type, title = "description"
//        case appBundleIds = "bundle_identifiers", appFilePaths = "file_paths"
//        case deviceIdentifiers = "identifiers"
//        case keyboardTypes = "keyboard_types"
//        case inputSources = "input_sources"
//        case variableName = "name", variableValue = "value"
//
//        fileprivate enum Types: String {
//            case appIs = "frontmost_application_if", appNot = "frontmost_application_unless"
//            case deviceIs = "device_if", deviceNot = "device_unless"
//            case keyboardIs = "keyboard_type_if", keyboardNot = "keyboard_type_unless"
//            case inputSourceIs = "input_source_if", inputSourceNot = "input_source_unless"
//            case variableIs = "variable_if", variableNot = "variable_unless"
//        }
//    }
//}

