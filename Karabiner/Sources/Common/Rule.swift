import Foundation

/// A rule is a dictionary of manipulators. The manipulator is what actually match inputs to outputs.
public struct Rule: Codable {
    /// A brief title/description about the the rule dictionary.
    public let title: String
    /// The list of the manipulators offered by this rule dictionary.
    public let manipulators: [Manipulator]
}

public extension Rule {
    public init(_ title: String, manipulators: [Manipulator]) throws {
        guard !title.isEmpty else { throw Rule.Error.invalidTitle(title) }
        guard !manipulators.isEmpty else { throw Rule.Error.invalidManipulators(manipulators) }
        (self.title, self.manipulators) = (title, manipulators)
    }
    
    /// List of possible errors thrown by the Karabiner rule.
    public enum Error: Swift.Error {
        case invalidTitle(String)
        case invalidManipulators([Manipulator])
    }

    fileprivate enum CodingKeys: String, CodingKey {
        case title="description", manipulators
    }
}
