//
//  ProtoCodableConverter.swift
//  ProtoCodable
//
//  Created by Kabir Oberai on 19/09/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation

// TODO: Maybe rename to ProtoCodableTransformer? (use similar API as [NS]ValueTransformer)

public protocol ProtoCodableConverter {
    associatedtype Value
    static func convert(raw: ProtoCodable) throws -> Value
    static func convert(value: Value) throws -> ProtoCodable
}

public struct ProtoCodableDirectConverter<T>: ProtoCodableConverter {
    public enum Error: LocalizedError {
        case notProtoCodable

        public var errorDescription: String? {
            switch self {
            case .notProtoCodable:
                return "\(T.self)".withCString {
                    String.localizedStringWithFormat(
                        NSLocalizedString("proto_codable_error.not_proto_codable", value: "Not ProtoCodable: %s", comment: ""), $0
                    )
                }
            }
        }
    }

    private static func convert<U, V>(_ value: U) throws -> V {
        guard let converted = value as? V else {
            throw Error.notProtoCodable
        }
        return converted
    }

    public static func convert(type: T.Type) throws -> ProtoCodable.Type {
        return try convert(type)
    }

    public static func convert(raw: ProtoCodable) throws -> T {
        return try convert(raw)
    }

    public static func convert(value: T) throws -> ProtoCodable {
        return try convert(value)
    }
}
