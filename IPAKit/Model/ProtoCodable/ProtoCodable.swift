//
//  ProtoCodable.swift
//  IPAKit
//
//  Created by Kabir Oberai on 28/05/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

// TODO: Make ProtoCodableIdentifier type (possibly enum) which specifies identifier mode: eg fromBase/custom. But maybe a bit more extensible so make it a String rawvaluerepresentable and put static methods on it to easily generate it from a base, etc

// Represents a codable protocol, where the concrete type can be decoded based on the identifier
public protocol ProtoCodable: Codable {
    static var identifier: String { get }
}

public extension ProtoCodable {
    static func identifier(withBaseName baseName: String? = nil) -> String {
        // Get the type's name, and remove the base name
        let typeName = "\(self)".split(separator: ".").last!
        if let baseName = baseName {
            return typeName.replacingOccurrences(of: baseName, with: "")
        } else {
            return String(typeName)
        }
    }
}

// caches the protocodable type mapping to each identifier, for different container types
private class ProtoCodableIdentifierMapper {
    static let shared = ProtoCodableIdentifierMapper()
    private init() {}

    // [ContainerType: [identifier: type]]
    var identifiers: [ObjectIdentifier: [String: ProtoCodable.Type]] = [:]

    func type<T: ProtoCodableContainer>(for identifier: String, in containerType: T.Type) -> ProtoCodable.Type? {
        let containerID = ObjectIdentifier(T.self)

        let identifierList: [String: ProtoCodable.Type]
        if let list = identifiers[containerID] {
            identifierList = list
        } else {
            identifierList = Dictionary(T.supportedTypes.map { ($0.identifier, $0) }, uniquingKeysWith: { a, _ in a })
            identifiers[containerID] = identifierList
        }

        return identifierList[identifier]
    }
}

// a struct that encodes ProtoCodable values with their identifier stored alongside
// values are decoded by comparing the identifier against those in the list provided by `T.allTypes`
public protocol ProtoCodableContainer: Codable {
    static var typeKey: String { get }

    // unfortunately we can't add a conformance clause here since then we wouldn't
    // be able to use a protocol as the concrete type, because protocols don't
    // conform to themselves
    associatedtype Value
    init(value: Value) throws
    var value: Value { get }

    // a type that converts between values of type Value and ProtoCodable.
    // since we can't guarantee that Value is ProtoCodable, our second best bet
    // is to guarantee that it can be converted

    // TODO: Somehow require Value: ProtoCodable if the converter is direct (or require the user to explicitly set a converter)
    associatedtype Converter: ProtoCodableConverter = ProtoCodableDirectConverter<Value> where Converter.Value == Value

    static var supportedTypes: [ProtoCodable.Type] { get }
}

private struct ProtoCodableCodingKeys: CodingKey {
    let stringValue: String
    var intValue: Int?

    init(_ string: String) {
        self.stringValue = string
    }
    init?(stringValue: String) {
        self.init(stringValue)
    }
    init?(intValue: Int) {
        return nil
    }
}

// TODO: Instead of this, maybe make a Configuration type which contains config options, since there may be other config options like whether the value should be nested (and if so, under what key name)
extension ProtoCodableContainer {
    public static var typeKey: String {
        return "type"
    }

    private static var typeCodingKey: ProtoCodableCodingKeys {
        return ProtoCodableCodingKeys(Self.typeKey)
    }
}

// encoding/decoding magic
public extension ProtoCodableContainer {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProtoCodableCodingKeys.self)

        let rawValue = try Converter.convert(value: value)

        // store a string representing the concrete type of `value`
        // used to avoid ambiguity when decoding
        let typeID = type(of: rawValue).identifier
        try container.encode(typeID, forKey: Self.typeCodingKey)

        // store the value itself
        try rawValue.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProtoCodableCodingKeys.self)

        // get the string that represents the concrete type of the ProtoCodable
        let typeID = try container.decode(String.self, forKey: Self.typeCodingKey)

        // find the ProtoCodable.Type in the type list that corresponds to the `type` String
        guard let protoCodableType = ProtoCodableIdentifierMapper.shared.type(for: typeID, in: Self.self) else {
            throw DecodingError.dataCorruptedError(
                forKey: Self.typeCodingKey,
                in: container,
                debugDescription: "Unknown type: \(typeID)"
            )
        }

        // create a ProtoCodable of that type using `decoder`
        let rawValue = try protoCodableType.init(from: decoder)
        try self.init(value: Converter.convert(raw: rawValue))
    }
}
