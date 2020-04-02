//
//  AnyEncodable.swift
//  Supercharge
//
//  Created by Kabir Oberai on 01/04/20.
//  Copyright © 2020 Kabir Oberai. All rights reserved.
//

import Foundation

// https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/5

extension Encodable {
    func encode(into container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
}

struct AnyEncodable: Encodable {
    var value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(into: &container)
    }
}

extension Encodable {
    func eraseToAnyEncodable() -> AnyEncodable { .init(self) }
}
