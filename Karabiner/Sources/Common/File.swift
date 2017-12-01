import Foundation

/// Karabiner file containing several rules/manipulators.
public struct File: Codable {
    /// The file's titles to be displayed right after loading it.
    public let title: String
    /// Rules are dictionaries containing each one different manipulators.
    public let rules: [Rule]
    
    /// Designated initializer to create a Karabiner file from the ground up.
    /// - parameter title: The title of the creating file.
    /// - parameter rules: All the rules hosted within the newly created file.
    public init(_ title: String, rules: [Rule]) {
        guard !title.isEmpty else { fatalError("The file's title is empty.") }
        guard !rules.isEmpty else { fatalError("The file's rules are empty.") }
        (self.title, self.rules) = (title, rules)
    }
}
