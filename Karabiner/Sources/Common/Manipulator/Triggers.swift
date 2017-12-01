import Foundation

/// Events sent after an input is recognized and a condition is met.
public struct Triggers: Codable {
    /// Events sent after the input is recognized.
    public let press: Set<Output>?
    /// Events sent after the input occurs alone (with no other interference).
    public let pressAlone: Set<Output>?
    /// Events sent after the input is released.
    public let release: Set<Output>?
    /// Events sent after a time delay (specified on the parameters dictionary).
    public let delayed: DelayedActions?
    
    /// Designated initializer
    public init(press: Set<Output>? = nil, pressAlone: Set<Output>? = nil, release: Set<Output>? = nil, delayed: (confirmed: Set<Output>?, cancelled: Set<Output>?)? = nil) {
        self.press = press.flatMap { $0.isEmpty ? nil : $0 }
        self.pressAlone = pressAlone.flatMap { $0.isEmpty ? nil : $0 }
        self.release = release.flatMap { $0.isEmpty ? nil : $0 }
        self.delayed = delayed.map { DelayedActions($0.confirmed, cancelled: $0.cancelled) }
        guard (self.press != nil) || (self.pressAlone != nil) || (self.release != nil) || (self.delayed != nil) else {
            fatalError("Triggers must define at least one output.")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case press="to", pressAlone="to_if_alone", release="to_after_key_up"
        case delayed="to_delayed_action"
    }
    
    public struct DelayedActions: Codable {
        /// Events sent after a default amount of milliseconds since the input was "pressed" (default = "500 milliseconds").
        public let confirmed: Set<Output>?
        /// Events sent if another input was triggered before the default amount of milliseconds past.
        public let cancelled: Set<Output>?
        
        /// Designated initializer
        public init(_ confirmed: Set<Output>? = nil, cancelled: Set<Output>? = nil) {
            self.confirmed = confirmed.flatMap { $0.isEmpty ? nil : $0 }
            self.cancelled = cancelled.flatMap { $0.isEmpty ? nil : $0 }
            guard (self.confirmed != nil) && (self.cancelled != nil) else {
                fatalError("Trigger's delayed actions must define at least one action.")
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case confirmed="to_if_invoked", cancelled="to_if_canceled"
        }
    }
}
