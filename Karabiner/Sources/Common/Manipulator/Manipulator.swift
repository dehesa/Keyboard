import Foundation

/// Complex modifications manipulators matching user input with one or more outputs.
///
/// Karabiner catch events in the following order:
/// 1. Catch events from hardware.
/// 2. Apply *Simple Modifications*.
/// 3. Apply *Complex Modifications*.
/// 4. Apply *Function Keys Modifications*.
/// 5. Post events to applications via a virtual keyboard.
/// - note: System modifier keys configurations in `System Preferences > Keyboard` are ignored.
public struct Manipulator: Codable {
    /// Optional description about what the manipulator does.
    public let title: String?
//    /// The type of manipulator.
//    ///
//    /// For now, this is always `Basic`.
//    public let type: Manipulator.Kind
//    /// The type of input that will be matched/recognized.
//    public let input: Input
//    /// The conditions for the input to be recognized and thus, for the outputs to be triggered.
//    public let conditions: [Condition]?
//    /// Sent events.
//    public let outputs: Triggers
//    /// Parameters to be applied for this specific manipulator.
//    public let parameters: Set<Parameter>?
//
//    /// Initializes a manipulator that will match the given input with one or more outputs.
//    /// - parameter title: The title for the manipulator to be displayed on the Karabiner app.
//    /// - parameter input: The input events to listen to.
//    /// - parameter conditions: The conditions applied for the input to be recognized.
//    /// - parameter outputs: The events to be sent when the input are triggered.
//    /// - parameter parameters: Parameters modifying the state for this specific manipulator.
//    public init(_ title: String? = nil, input: Input, conditions: [Condition]? = nil, outputs: Triggers, parameters: Set<Parameter>? = nil) {
//        self.title = title.flatMap { $0.isEmpty ? nil : $0 }
//        self.type = .basic
//        self.input = input
//        self.conditions = conditions.flatMap { $0.isEmpty ? nil : $0 }
//        self.outputs = outputs
//        self.parameters = parameters.flatMap { $0.isEmpty ? nil : $0 }
//    }
//
//    public enum Kind: String, Codable {
//        case basic
//    }
}
//
//public extension Manipulator {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let _ = try container.decode(Kind.self, forKey: .type)
//        let title = try container.decodeIfPresent(String.self, forKey: .title)
//        let input = try container.decode(Input.self, forKey: .input)
//        let conditions = try container.decodeIfPresent([Condition].self, forKey: .conditions)
//        let outputs = try Triggers(from: decoder)
//
//        var parameters = Set<Parameter>()
//        if container.contains(.parameters) {
//            let nested = try container.nestedContainer(keyedBy: Parameter.CodingKeys.self, forKey: .parameters)
//            for key in nested.allKeys {
//                parameters.insert(try Parameter(key: key, container: nested))
//            }
//        }
//        self.init(title, input: input, conditions: conditions, outputs: outputs, parameters: parameters)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encodeIfPresent(self.title, forKey: .title)
//        try container.encode(self.type, forKey: .type)
//        try container.encode(self.input, forKey: .input)
//        try container.encodeIfPresent(self.conditions, forKey: .conditions)
//        try self.outputs.encode(to: encoder)
//        if let parameters = self.parameters, !parameters.isEmpty {
//            var nestedContainer = container.nestedContainer(keyedBy: Parameter.CodingKeys.self, forKey: .parameters)
//            for param in parameters {
//                try param.encode(on: &nestedContainer)
//            }
//        }
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case title="description"
//        case type, input="from", conditions, parameters
//    }
//}
