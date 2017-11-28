import Foundation

public extension Manipulator {
    /// One parameters that can be set up for a manipulator.
    public enum Parameter: Hashable, Encodable {
        case delay(seconds: TimeInterval)
    }
}

public extension Manipulator.Parameter {
    public var hashValue: Int {
        switch self {
        case .delay(seconds: let seconds): return (1 << 1) ^ seconds.hashValue
        }
    }
    
    public static func == (lhs: Manipulator.Parameter, rhs: Manipulator.Parameter) -> Bool {
        switch (lhs, rhs) {
        case (.delay(seconds: let left), .delay(seconds: let right)): return left == right
        // default: return false
        }
    }
    
    internal init(key: CodingKeys, container: KeyedDecodingContainer<CodingKeys>) throws {
        switch key {
        case .delay: self = .delay(seconds: try container.decode(TimeInterval.self, forKey: key))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .delay(seconds: let seconds): try container.encode(seconds, forKey: .delay)
        }
    }
    
    internal enum CodingKeys: String, CodingKey {
        case delay = "to_delayed_action_delay_milliseconds"
    }
}
