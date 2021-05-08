//
//  CodableUtils.swift
//  Superutils
//
//  Created by Kabir Oberai on 07/12/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

public struct EitherDecodable<First: Decodable, Second: Decodable>: Decodable {

    public enum Value {
        case first(First)
        case second(Second)
    }

    public let value: Value

    public init(from decoder: Decoder) throws {
        value = try (try? .first(First(from: decoder))) ?? .second(Second(from: decoder))
    }

}

// either a number or a string containing a number
public struct PossiblyStringifiedNumber: Codable {
    public let value: Int

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let stringValue = try? container.decode(String.self),
            let value = Int(stringValue) {
            self.value = value
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected Int or String")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// either an array of type T or a single value of type T
public struct PossiblyFlatArray<T: Codable>: Codable {
    public let elements: [T]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let elements = try? container.decode([T].self) {
            self.elements = elements
        } else {
            self.elements = [try container.decode(T.self)]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

public extension Encodable {
    func jsonValue(withEncoder encoder: JSONEncoder = .init()) throws -> Any {
        let data = try encoder.encode([self])
        let arr = try JSONSerialization.jsonObject(with: data) as! [Any]
        return arr[0]
    }

    func plistValue(withEncoder encoder: PropertyListEncoder = .init()) throws -> Any {
        let data = try encoder.encode([self])
        let arr = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [Any]
        return arr[0]
    }
}
