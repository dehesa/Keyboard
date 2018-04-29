public struct LadenSet<Element>: ExpressibleByArrayLiteral, Equatable, Hashable where Element: Hashable {
    fileprivate var elements: Set<Element>
    
    public init(arrayLiteral elements: Element...) {
        guard !elements.isEmpty else { fatalError("LadenSet cannot be empty.") }
        self.elements = Set<Element>(elements)
    }
}

extension LadenSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public enum Error: Swift.Error {
        case insufficientLength
    }
    
    public var description: String {
        return self.elements.description
    }
    
    public var debugDescription: String {
        return self.elements.debugDescription
    }
    
    public var customMirror: Mirror {
        return self.elements.customMirror
    }
}

extension LadenSet: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode(Set<Element>.self)
        guard !elements.isEmpty else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "A LadenSet must contain at least one element.")
            throw DecodingError.typeMismatch(LadenArray<Element>.self, context)
        }
        self.elements = elements
    }
}

extension LadenSet: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.elements)
    }
}
