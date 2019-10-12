//
//  ProtoCodableKeyedTypeContainer.swift
//  IPAKit
//
//  Created by Kabir Oberai on 19/09/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation

private struct ProtoCodableKeyedTypeCodingKeys: CodingKey {
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

// a ProtoCodableContainer which stores the type as a separate key
public protocol ProtoCodableKeyedTypeContainer: Codable, ProtoCodableContainer {
    static var typeKey: String { get }
}

extension ProtoCodableKeyedTypeContainer {
    public static var typeKey: String {
        return "type"
    }

    private static var typeCodingKey: ProtoCodableKeyedTypeCodingKeys {
        return ProtoCodableKeyedTypeCodingKeys(Self.typeKey)
    }
}

extension ProtoCodableKeyedTypeContainer {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProtoCodableKeyedTypeCodingKeys.self)
        try encodeWithIdentifier { identifier in
            try container.encode(identifier, forKey: Self.typeCodingKey)
            return encoder
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ProtoCodableKeyedTypeCodingKeys.self)
        let typeID = try container.decode(String.self, forKey: Self.typeCodingKey)
        try self.init(from: decoder, identifier: typeID)
    }
}
