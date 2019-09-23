//
//  ProtoCodableKeyValueContainer.swift
//  IPAKit
//
//  Created by Kabir Oberai on 19/09/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation

// a ProtoCodableContainer which stores the type as the container's key
public struct ProtoCodableKeyValueContainer<T: ProtoCodableContainer>: Codable {
    private struct CodingKeys: CodingKey {
        let stringValue: String
        init(stringValue: String) {
            self.intValue = nil
            self.stringValue = stringValue
        }

        let intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    public let containers: [T]
    public init(containers: [T]) {
        self.containers = containers
    }

    public var values: [T.Value] {
        return containers.map { $0.value }
    }
    public init(values: [T.Value]) throws {
        self.containers = try values.map(T.init(value:))
    }
}

extension ProtoCodableKeyValueContainer {
    public func encode(to encoder: Encoder) throws {
        var rootContainer = encoder.container(keyedBy: CodingKeys.self)
        for container in containers {
            try container.encodeWithIdentifier { identifier in
                rootContainer.superEncoder(forKey: CodingKeys(stringValue: identifier))
            }
        }
    }

    public init(from decoder: Decoder) throws {
        var containers: [T] = []
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        for key in rootContainer.allKeys {
            let keyDecoder = try rootContainer.superDecoder(forKey: key)
            let container = try T(from: keyDecoder, identifier: key.stringValue)
            containers.append(container)
        }
        self.containers = containers
    }
}
