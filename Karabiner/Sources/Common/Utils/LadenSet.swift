/// Set that cannot be empty. There will always be at least one element.
///
/// This structure is backed by a normal Swift library set.
public struct LadenSet<Element>: ExpressibleByArrayLiteral, Hashable where Element: Hashable {
    /// Storage to back all elements.
    fileprivate var elements: Set<Element>
    
    public init(arrayLiteral elements: Element...) {
        guard !elements.isEmpty else { fatalError("LadenSet cannot be empty.") }
        self.elements = Set<Element>(elements)
    }
    
    /// Creates a non-empty set with the elements of the given set.
    ///
    /// If the set is empty, `nil` is returned.
    /// - parameter set: The elements to use as members of the new set.
    public init?(set: Set<Element>) {
        guard !set.isEmpty else { return nil }
        self.elements = set
    }
    
    /// Creates a non-empty set with one element. Optionally a minimum capacity can be configured.
    /// - parameter member: The first member to be added to the non-empty set.
    /// - parameter minimumCapacity: The minimum number of elements that the newly created set should be able to store without reallocating its buffer.
    public init(_ member: Element, minimumCapacity: Int = 1) {
        self.elements = Set<Element>(minimumCapacity: minimumCapacity)
        self.elements.insert(member)
    }
    
    /// The total number of elements that the set can contain without allocating new storage.
    public var capacity: Int {
        return self.elements.capacity
    }
    
    /// Reserves enough space to store the specified number of elements.
    ///
    /// If you are adding a known number of elements to a set, use this method to avoid multiple reallocations. This method ensures that the set has unique, mutable, contiguous storage, with space allocated for at least the requested number of elements.
    /// Calling the `reserveCapacity(_:)` method on a set with bridged storage triggers a copy to contiguous storage even if the existing storage has room to store minimumCapacity elements.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        self.elements.reserveCapacity(minimumCapacity)
    }
    
    /// The number of elements in the set.
    public var count: Int {
        return self.elements.count
    }
    
    /// The first element of the set.
    ///
    /// The first element of the set is not necessarily the first element added to the set. Don’t expect any particular ordering of set elements.
    public var first: Element {
        return self.elements.first!
    }
    
    /// Returns a non-empty set containing the results of mapping the given closure over the sequence’s elements.
    /// - parameter transform: A mapping closure. transform accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    public func map<T:Hashable>(_ transform: (Element) throws -> T) rethrows -> LadenSet<T> {
        var result = Set<T>(minimumCapacity: self.elements.capacity)
        for element in self.elements {
            result.insert(try transform(element))
        }
        return LadenSet<T>(set: result)!
    }
    
    /// Returns a non-empty set containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// If the result is empty, `nil` is returned.
    /// - parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    public func compactMap<T:Hashable>(_ transform: (Element) throws -> T?) rethrows -> LadenSet<T>? {
        var result = Set<T>(minimumCapacity: self.elements.capacity)
        for element in self.elements {
            guard let transformed = try transform(element) else { continue }
            result.insert(transformed)
        }
        result.reserveCapacity(result.count)
        return LadenSet<T>(set: result)
    }
    
    /// Returns a new non-empty set containing the elements of the set that satisfy the given predicate, or `nil` if no members are included in the result.
    /// - parameter isIncluded: A closure that takes an element as its argument and returns a Boolean value indicating whether the element should be included in the returned set.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LadenSet<Element>? {
        var result = Set<Element>()
        for element in self {
            if try isIncluded(element) {
                result.insert(element)
            }
        }
        return LadenSet<Element>(set: result)
    }
}

extension LadenSet: Collection {
    public typealias Index = Set<Element>.Index
    
    public var startIndex: Index {
        return self.elements.startIndex
    }
    
    public var endIndex: Index {
        return self.elements.endIndex
    }
    
    public func index(after i: Index) -> Index {
        return self.elements.index(after: i)
    }
    
    public subscript(_ index: Index) -> Element {
        return self.elements[index]
    }
}

extension LadenSet {    // Most of SetAlgebra methods.
    /// Create a new non-empty set from a finite sequence of items.
    ///
    /// If the sequence is empty, `nil` is returned.
    /// - parameter sequence: The elements to use as members of the new set.
    public init?<S:Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        self.init(set: Set<Element>(sequence))
    }
    
    /// Returns a Boolean value that indicates whether the given element exists in the set.
    /// - parameter member: An element to look for in the set.
    public func contains(_ member: Element) -> Bool {
        return self.elements.contains(member)
    }
    
    /// Inserts the given element in the set if it is not already present.
    /// - parameter newMember: An element to insert into the set.
    /// - returns: `(true, newMember)` is `newMember` was not contained in the set. If an element equal to `newMember` was already contained in the set, the method returns `(false, oldMember)`, where `oldMember` is the element that was equal to `newMember`. In some case, `oldMember` may be distinguishable from `newMember` by identity comparison or some other means.
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        return self.elements.insert(newMember)
    }
    
    /// Inserts the given element into the set unconditionally.
    /// - parameter newMember: An element to insert into the set.
    /// - returns: An element equal to `newMember` if the set already contained such a member; otherwise, `nil`. In some cases, the returned element may be distinguishable from `newMember` by identity comparison or some other means.
    public mutating func update(with newMember: Element) -> Element? {
        return self.elements.update(with: newMember)
    }
    
    /// Removes the specified element from the set.
    /// - parameter member: The element to remove from the set.
    /// - returns: The value of the `member` parameter if it was a member of the set; otherwise, `nil`.
    public mutating func remove(_ member: Element) throws -> Element? {
        guard self.elements.count > 1 else { throw LadenSet.Error.insufficientLength }
        return self.elements.remove(member)
    }
    
    /// Returns a new set with the elements of both this and the given set.
    /// - parameter other: A set of the same type as the current set.
    public func union(_ other: LadenSet<Element>) -> LadenSet<Element> {
        return LadenSet<Element>(set: self.elements.union(other.elements))!
    }
    
    /// Adds the elements of the given set to the set.
    /// - parameter other: A set of the same type as the current set.
    public mutating func formUnion(_ other: LadenSet<Element>) {
        self.elements.formUnion(other.elements)
    }
    
    /// Returns a new set with the elements that are common to both this set and the given set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: A new non-empty set or `nil` if the intersection didn't match any element.
    public func intersection(_ other: LadenSet<Element>) -> LadenSet<Element>? {
        return LadenSet<Element>(set: self.elements.intersection(other.elements))
    }
    
    /// Returns a new set with the elements that are either in this set or in the given set, but not in both.
    /// - parameter other: A set of the same type as the current set.
    public func symmetricDifference(_ other: LadenSet<Element>) -> LadenSet<Element>? {
        return LadenSet<Element>(set: self.elements.symmetricDifference(other.elements))
    }
    
    /// Returns a new set containing the elements of this set that do not occur in the given set.
    /// - parameter other: A set of the same type as the current set.
    public func subtracting(_ other: LadenSet<Element>) -> LadenSet<Element>? {
        return LadenSet<Element>(set: self.elements.subtracting(other.elements))
    }
    
    /// Returns a Boolean value that indicates whether the set is a subset of another set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: `true` if the set is a subset of other; otherwise, false.
    public func isSubset(of other: LadenSet<Element>) -> Bool {
        return self.elements.isSubset(of: other.elements)
    }
    
    /// Returns a Boolean value that indicates whether this set is a strict subset of the given set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: `true` if the set is a strict subset of `other`; otherwise, `false`.
    public func isStrictSubset(of other: LadenSet<Element>) -> Bool {
        return self.elements.isStrictSubset(of: other.elements)
    }
    
    /// Returns a Boolean value that indicates whether the set is a superset of the given set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: `true` if the set is a super subset of `other`; otherwise, `false`.
    public func isSuperset(of other: LadenSet<Element>) -> Bool {
        return self.elements.isSuperset(of: other.elements)
    }
    
    /// Returns a Boolean value that indicates whether this set is a strict superset of the given set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: `true` if the set is a strict superset of `other`; otherwise, `false`.
    public func isStrictSuperset(of other: LadenSet<Element>) -> Bool {
        return self.elements.isStrictSuperset(of: other.elements)
    }
    
    /// Returns a Boolean value that indicates whether the set has no members in common with the given set.
    /// - parameter other: A set of the same type as the current set.
    /// - returns: `true` if the set has no elements in common with `other`; otherwise, `false`.
    public func isDisjoint(with other: LadenSet<Element>) -> Bool {
        return self.elements.isDisjoint(with: other.elements)
    }
}

extension LadenSet: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// List of errors generated by this non-empty set.
    public enum Error: Swift.Error {
        /// The operation computed a length of zero (or less). `LadenSet`s cannot be empty.
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
