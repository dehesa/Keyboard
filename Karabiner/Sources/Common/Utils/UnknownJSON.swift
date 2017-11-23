import Foundation

public enum JSON {
    public struct UnknownValue: Codable {
        public let content: Encodable?
        
        public init(_ value: Encodable) {
            self.content = value
        }
    }
    
    /// Represents a key not mapped with a `CodingKey` enum.
    internal struct UnknownKey: CodingKey {
        /// The encoded/decoded key string.
        let key: String
        
        init?(intValue: Int) { return nil }
        var intValue: Int? { return nil }
        
        init?(stringValue: String) { self.key = stringValue }
        init(_ key: String) { self.key = key }
        var stringValue: String { return self.key }
    }
}

public extension JSON.UnknownValue {
    public init(from decoder: Decoder) throws {
        if let dictionary = try? decoder.container(keyedBy: JSON.UnknownKey.self) {
            var result: [String:Encodable?] = [:]
            for key in dictionary.allKeys {
                let element = try dictionary.decode(JSON.UnknownValue.self, forKey: key)
                result[key.key] = element.content
            }
            self.content = result
        } else if var array = try? decoder.unkeyedContainer() {
            var result: [Encodable?] = []
            while !array.isAtEnd {
                let element = try array.decode(JSON.UnknownValue.self)
                result.append(element.content)
            }
            self.content = result
        } else if let value = try? decoder.singleValueContainer() {
            if value.decodeNil() {
                self.content = nil
            } else if let boolean = try? value.decode(Bool.self) {
                self.content = boolean
            } else if let integer = try? value.decode(Int.self) {
                self.content = integer
            } else if let number = try? value.decode(Double.self) {
                self.content = number
            } else if let date = try? value.decode(Date.self) {
                self.content = date
            } else if let string = try? value.decode(String.self) {
                self.content = string
            } else {
                throw DecodingError.dataCorruptedError(in: value, debugDescription: "The single value container was not a JSON primitive")
            }
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The decoder experienced an error trying to get a container (whether single, unkeyed, keyed).")
            throw DecodingError.dataCorrupted(context)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        // First check if we have `nil`.
        guard let value = self.content else {
            var container = encoder.singleValueContainer()
            return try container.encodeNil()
        }
        
        // Lets take the complex JSON primitives next (a.k.a. dictionaries and arrays.
        if let dictionary = value as? [String:Encodable] {
            var container = encoder.container(keyedBy: JSON.UnknownKey.self)
            for (key, value) in dictionary {
                try container.encode(JSON.UnknownValue(value), forKey: JSON.UnknownKey(key))
            }; return
        } else if let array = value as? [Encodable] {
            var container = encoder.unkeyedContainer()
            for element in array {
                try container.encode(JSON.UnknownValue(element))
            }; return
        }
        
        // Only single values are left.
        var container = encoder.singleValueContainer()
        
        if let boolean = value as? Bool {
            try container.encode(boolean)
        } else if let date = value as? Date {
            try container.encode(date)
        } else if let url = value as? URL {
            try container.encode(url)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let signed = value as? Int {
            try container.encode(signed)
        } else if let unsigned = value as? UInt {
            try container.encode(unsigned)
        } else if let float = value as? Float {
            try container.encode(float)
        } else if let double = value as? Double {
            try container.encode(double)
        } else {
            let context = EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "The value could not be encoded. To fix it, make the value `Encodable` and add that type to the `JSON.UnknownValue.encode(to:)` function")
            throw EncodingError.invalidValue(value, context)
        }
    }
}
