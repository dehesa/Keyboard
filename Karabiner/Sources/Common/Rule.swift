import Foundation

/// A rule is a dictionary of manipulators. The manipulator is what actually match inputs to outputs.
public struct Rule: Codable {
    /// A brief title/description about the the rule dictionary.
    public let title: String
    /// The list of the manipulators offered by this rule dictionary.
    public let manipulators: [Manipulator]

    /// Designated initializer for defining a new Karabiner rule.
    /// - parameter title: The title/description of the definied rule.
    /// - parameter manipulators: The defined list of manipulators (all are unique).
    public init(_ title: String, manipulators: [Manipulator]) {
        guard !title.isEmpty else { fatalError("The rule's title is empty.") }
        guard !manipulators.isEmpty else { fatalError("The rule's manipulators are empty.") }
        (self.title, self.manipulators) = (title, manipulators)
    }

    private enum CodingKeys: String, CodingKey {
        case title="description", manipulators
    }
}
