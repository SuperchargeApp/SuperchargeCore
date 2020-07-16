//
//  ProtoCodable.swift
//  IPAKit
//
//  Created by Kabir Oberai on 28/05/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

// TODO: Make ProtoCodableIdentifier type (possibly enum) which specifies identifier mode
// eg fromBase/custom. But maybe a bit more extensible so make it a String RawRepresentable
// and put static methods on it to easily generate it from a base, etc

// TODO: Localize
public enum ProtoCodableError: Error {
    case unknownType(String, containerType: String)
}

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
public class ProtoCodableIdentifierMapper {
    public static let shared = ProtoCodableIdentifierMapper()
    private init() {}

    // [ContainerType: [identifier: type]]
    private var identifiers: [ObjectIdentifier: [String: ProtoCodable.Type]] = [:]

    public func type<T: ProtoCodableContainer>(
        for identifier: String, in containerType: T.Type
    ) -> ProtoCodable.Type? {
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

/// a struct that encodes ProtoCodable values with their identifier stored alongside
/// values are decoded by comparing the identifier against those in the list provided by `T.allTypes`
public protocol ProtoCodableContainer {
    // unfortunately we can't add a conformance clause here since then we wouldn't
    // be able to use a protocol as the concrete type, because protocols don't
    // conform to themselves
    associatedtype Value
    init(value: Value) throws
    var value: Value { get set }

    // a type that converts between values of type Value and ProtoCodable.
    // since we can't guarantee that Value is ProtoCodable, our second best bet
    // is to guarantee that it can be converted

    // TODO: Somehow require Value: ProtoCodable if the converter is direct (or require the user to explicitly set a converter)
    associatedtype Converter: ProtoCodableConverter = ProtoCodableDirectConverter<Value> where Converter.Value == Value

    /// encodes the value in the encoder provided by the closure
    func encodeWithIdentifier(generateEncoder: (String) throws -> Encoder) throws
    /// decodes a value from the given identifier
    init(from decoder: Decoder, identifier: String) throws

    // TODO: Implement encodeWithIdentifier and decode(withIdentifier:) in ProtoCodableContainer,
    // and create sub-protocols which implement encode and decode based on the above methods
    // (one just encodes the key in the main container, the other is a dict representation thing

    /// the list of supported `ProtoCodable` types
    static var supportedTypes: [ProtoCodable.Type] { get }
}

// https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/5
private extension Encodable {
    func encode(into container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

// encoding/decoding magic
public extension ProtoCodableContainer {
    static func protoCodableType(for identifier: String) -> ProtoCodable.Type? {
        return ProtoCodableIdentifierMapper.shared.type(for: identifier, in: Self.self)
    }

    func encodeWithIdentifier(generateEncoder: (String) throws -> Encoder) throws {
        let rawValue = try Converter.convert(value: value)
        let identifier = type(of: rawValue).identifier
        let encoder = try generateEncoder(identifier)
        try rawValue.encode(to: encoder)
        #warning("Using encode(info:) appears to make IPAKit.NilParameter crash.")
        // when that's fixed we should go back to using encode(into:)
    }

    init(from decoder: Decoder, identifier: String) throws {
        // find the ProtoCodable.Type in the type list that corresponds to the `type` String
        guard let protoCodableType = Self.protoCodableType(for: identifier) else {
            throw ProtoCodableError.unknownType(identifier, containerType: "\(Self.self)")
        }
        // create a ProtoCodable of that type using `decoder`
        let rawValue = try protoCodableType.init(from: decoder)
        try self.init(value: Converter.convert(raw: rawValue))
    }
}
