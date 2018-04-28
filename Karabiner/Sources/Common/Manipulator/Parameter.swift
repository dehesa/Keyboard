//import Foundation
//
///// One parameters that can be set up for a manipulator.
//public enum Parameter: Hashable {
//    /// Default is 0.5 seconds
//    case delay(seconds: TimeInterval)
//    /// Default is 1.0 seconds
//    case pressAlone(seconds: TimeInterval)
//    
//    internal init(key: CodingKeys, container: KeyedDecodingContainer<CodingKeys>) throws {
//        switch key {
//        case .delay:
//            let milliseconds = try container.decode(Double.self, forKey: key)
//            self = .delay(seconds: milliseconds.toSeconds)
//        case .pressAlone:
//            let milliseconds = try container.decode(Double.self, forKey: key)
//            self = .pressAlone(seconds: milliseconds.toSeconds)
//        }
//    }
//    
//    internal func encode(on container: inout KeyedEncodingContainer<CodingKeys>) throws {
//        switch self {
//        case .delay(seconds: let seconds):      try container.encode(seconds.toMilliseconds, forKey: .delay)
//        case .pressAlone(seconds: let seconds): try container.encode(seconds.toMilliseconds, forKey: .pressAlone)
//        }
//    }
//    
//    internal enum CodingKeys: String, CodingKey {
//        case delay = "to_delayed_action_delay_milliseconds"
//        case pressAlone = "to_if_alone_timeout_milliseconds"
//    }
//}
//
//extension Parameter {
//    public var hashValue: Int {
//        switch self {
//        case .delay(seconds: let seconds):      return (1 << 1) ^ seconds.hashValue
//        case .pressAlone(seconds: let seconds): return (1 << 2) ^ seconds.hashValue
//        }
//    }
//    
//    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
//        switch (lhs, rhs) {
//        case (.delay(seconds: let left), .delay(seconds: let right)): return left == right
//        case (.pressAlone(seconds: let left), .pressAlone(seconds: let right)): return left == right
//        default: return false
//        }
//    }
//}
//
//private extension Double {
//    /// Transform the receiving value (given in milliseconds) into seconds.
//    var toSeconds: TimeInterval {
//        return self / 1000
//    }
//}
//
//private extension TimeInterval {
//    /// Transform the receiving value (given in seconds) into milliseconds.
//    var toMilliseconds: Double {
//        return self * 1000
//    }
//}
//
