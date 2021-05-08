//
//  AnyEncodable.swift
//  Superutils
//
//  Created by Kabir Oberai on 01/04/20.
//  Copyright © 2020 Kabir Oberai. All rights reserved.
//

import Foundation

// https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/5

public extension Encodable {
    func encode(into container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

public struct AnyEncodable: Encodable {
    public var value: Encodable

    public init(_ value: Encodable) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(into: &container)
    }
}

public extension Encodable {
    func eraseToAnyEncodable() -> AnyEncodable { .init(self) }
}
