/// Array that cannot be empty. There will always be at least one element.
///
/// This structure is backed by a normal Swift library array.
public struct LadenArray<Element>: ExpressibleByArrayLiteral {
    /// Storage to back all elements.
    fileprivate var elements: [Element]
    
    public init(arrayLiteral elements: Element...) {
        guard !elements.isEmpty else { fatalError("LadenArray cannot be empty.") }
        self.elements = elements
    }
    
    /// Creates a non-empty array with the elements with the elements of the given array.
    ///
    /// If the given array is emtpy, `nil` is returned.
    /// - parameter array: The elements to use as members of the new array.
    public init?(array: [Element]) {
        guard !array.isEmpty else { return nil }
        self.elements = array
    }
    
    /// The number of elements in the array.
    public var count: Int {
        return self.elements.count
    }
    
    /// The first element of the non-empty array.
    public var first: Element {
        return self.elements[0]
    }
    
    /// The last element of the non-empty array.
    public var last: Element {
        return self.elements[self.elements.endIndex-1]
    }
    
    // Returns a non-empty array containing the results of mapping the given closure over the sequence’s elements.
    /// - parameter transform: A mapping closure. transform accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> LadenArray<T> {
        return LadenArray<T>(array: try self.elements.map(transform))!
    }
    
    /// Returns a non-empty array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// If the result is empty, `nil` is returned.
    /// - parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> LadenArray<T>? {
        return LadenArray<T>(array: try self.elements.compactMap(transform))
    }
}

extension LadenArray: BidirectionalCollection, Collection, MutableCollection, RandomAccessCollection {
    public typealias Index = Int
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.count
    }
    
    public func index(before i: Int) -> Int {
        return self.elements.index(before: i)
    }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public subscript(_ index: Int) -> Element {
        get {
            return self.elements[index]
        }
        set {
            self.elements[index] = newValue
        }
    }
}

extension LadenArray {   // Simulation of many RangeReplaceableCollection.
    /// Create a new non-empty array from a finite sequence of items.
    ///
    /// If the sequence is empty, `nil` is returned.
    /// - parameter sequence: The elements to use as members of the new array.
    public init?<S:Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        self.init(array: Array<Element>(sequence))
    }
    
    public init?(repeating repeatedValue: Element, count: Int) {
        guard count > 0 else { return nil }
        self.elements = Array<Element>(repeating: repeatedValue, count: count)
    }
    
    public mutating func append(_ newElement: Element) {
        self.elements.append(newElement)
    }
    
    public mutating func append<S:Sequence>(contentsOf newElements: S) where S.Iterator.Element == Element {
        self.elements.append(contentsOf: newElements)
    }
    
    public func appending(_ newElement: Element) -> LadenArray<Element> {
        var copy = self
        copy.append(newElement)
        return copy
    }
    
    public mutating func insert(_ newElement: Element, at i: Index) {
        self.elements.insert(newElement, at: i)
    }
    
    public mutating func insert<C:Collection>(contentsOf collection: C, at index: Index) where C.Iterator.Element == Element {
        self.elements.insert(contentsOf: collection, at: index)
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LadenArray<Element>? {
        return LadenArray<Element>(array: try self.elements.filter(isIncluded))
    }
    
    public mutating func removeFirst() throws -> Element {
        guard self.elements.count > 1 else { throw LadenArray.Error.insufficientLength }
        return self.elements.removeFirst()
    }
    
    public mutating func removeFirst(_ n: Int) throws {
        guard self.elements.count > n else { throw LadenArray.Error.insufficientLength }
        return self.elements.removeFirst(n)
    }
    
    public mutating func remove(at index: Index) throws -> Element {
        guard self.elements.count > 1 else { throw LadenArray.Error.insufficientLength }
        return self.elements.remove(at: index)
    }
    
    public mutating func removeLast() throws -> Element {
        guard self.elements.count > 1 else { throw LadenArray.Error.insufficientLength }
        return self.elements.removeLast()
    }
    
    public mutating func removeLast(_ n: Int) throws {
        guard self.elements.count > n else { throw LadenArray.Error.insufficientLength }
        return self.elements.removeLast(n)
    }
    
    public static func + <S:Sequence>(lhs: LadenArray<Element>, rhs: S) -> LadenArray<Element> where S.Iterator.Element == Element {
        return LadenArray<Element>(array: lhs.elements + rhs)!
    }
    
    public static func += <S:Sequence>(lhs: inout LadenArray<Element>, rhs: S) where S.Iterator.Element == Element {
        lhs = lhs + rhs
    }
}

extension LadenArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
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

extension LadenArray: Equatable where Element: Equatable {
    public static func == (lhs: LadenArray<Element>, rhs: LadenArray<Element>) -> Bool {
        return lhs.elements == rhs.elements
    }
}

extension LadenArray: Decodable where Element: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let elements = try container.decode(Array<Element>.self)
        guard !elements.isEmpty else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "A LadenArray must contain at least one element.")
            throw DecodingError.typeMismatch(LadenArray<Element>.self, context)
        }
        self.elements = elements
    }
}

extension LadenArray: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.elements)
    }
}

extension LadenArray where Element: Comparable {
    public func sorted() -> LadenArray<Element> {
        return LadenArray<Element>(array: self.elements.sorted())!
    }
    
    public mutating func sort() {
        self.elements.sort()
    }
    
    public func min() -> Element {
        return self.elements.min()!
    }
    
    public func max() -> Element {
        return self.elements.max()!
    }
}

extension LadenArray where Element: StringProtocol {
    public func joined(separator: String) -> String {
        return self.elements.joined(separator: separator)
    }
}

extension LadenArray where Element == String {
    public func joined(separator: String) -> String {
        return self.elements.joined(separator: separator)
    }
}
