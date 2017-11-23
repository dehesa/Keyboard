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
    /// The type of manipulator.
    public let type: Kind
    /// The type of input that will be matched/recognized.
    public let input: Input
    /// Events sent after the input is recognized.
    public let outputs: [Output]
    /// The conditions for the input to be recognized and thus, for the outputs to be triggered.
    public let conditions: [Condition]?
    /// Parameters to be applied for this specific manipulator.
    // public let parameters: [Parameter]?
}

public extension Manipulator {
    public enum Kind: String, Codable {
        case basic
    }

    fileprivate enum CodingKeys: String, CodingKey {
        case title="description"
        case type
        case input="from", outputs="to"
        case conditions
        // parameters
//        case to, toAlone="to_if_alone", toUp="to_after_key_up"
//        case toDelayed="to_delayed_action", toDelayedInvoked="to_if_invoked", toDelayedCanceled="to_if_canceled"
    }
}
