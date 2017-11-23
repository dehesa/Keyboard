import Foundation

/// Karabiner file containing several rules/manipulators.
public struct File: Codable {
    /// The file's titles to be displayed right after loading it.
    public let title: String
    /// Rules are dictionaries containing each one different manipulators.
    public let rules: [Rule]
}

public extension File {
    /// Designated initializer to create a Karabiner file from the ground up.
    public init(_ title: String, rules: [Rule]) throws {
        guard !title.isEmpty else { throw File.Error.invalidTitle(title) }
        guard !rules.isEmpty else { throw File.Error.invalidRules(rules) }
        (self.title, self.rules) = (title, rules)
    }
    
    /// List of possible errors thrown by the Karabiner files.
    public enum Error: Swift.Error {
        case invalidTitle(String)
        case invalidRules([Rule])
    }
}
