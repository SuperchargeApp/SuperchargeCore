//
//  CodableElement.swift
//  Supersign
//
//  Created by Kabir Oberai on 11/10/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation

indirect enum CodableElement: Codable {
    private struct CodingKeys: CodingKey {
        let stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        let intValue: Int?
        init?(intValue: Int) {
            // no int keys in plist
            return nil
        }
    }

    case dictionary([String: CodableElement])
    case array([CodableElement])
    case `nil`
    case bool(Bool)
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case double(Double)
    case data(Data)
    case date(Date)
    case string(String)

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self = .dictionary(.init(uniqueKeysWithValues: try container.allKeys.map {
                ($0.stringValue, try container.decode(CodableElement.self, forKey: $0))
            }))
            return
        }

        if var container = try? decoder.unkeyedContainer() {
            var arr: [CodableElement] = []
            while !container.isAtEnd {
                arr.append(try container.decode(CodableElement.self))
            }
            self = .array(arr)
            return
        }

        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .nil
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Int8.self) {
            self = .int8(value)
        } else if let value = try? container.decode(Int16.self) {
            self = .int16(value)
        } else if let value = try? container.decode(Int32.self) {
            self = .int32(value)
        } else if let value = try? container.decode(Int64.self) {
            self = .int64(value)
        } else if let value = try? container.decode(UInt.self) {
            self = .uint(value)
        } else if let value = try? container.decode(UInt8.self) {
            self = .uint8(value)
        } else if let value = try? container.decode(UInt16.self) {
            self = .uint16(value)
        } else if let value = try? container.decode(UInt32.self) {
            self = .uint32(value)
        } else if let value = try? container.decode(UInt64.self) {
            self = .uint64(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Data.self) {
            self = .data(value)
        } else if let value = try? container.decode(Date.self) {
            self = .date(value)
        } else {
            let value = try container.decode(String.self)
            self = .string(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        func encodeSingleValue<T: Encodable>(_ value: T) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }

        switch self {
        case .dictionary(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try value.forEach { try container.encode($1, forKey: CodingKeys(stringValue: $0)) }
        case .array(let value):
            var container = encoder.unkeyedContainer()
            try value.forEach { try container.encode($0) }
        case .nil:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        case .bool(let value): try encodeSingleValue(value)
        case .int(let value): try encodeSingleValue(value)
        case .int8(let value): try encodeSingleValue(value)
        case .int16(let value): try encodeSingleValue(value)
        case .int32(let value): try encodeSingleValue(value)
        case .int64(let value): try encodeSingleValue(value)
        case .uint(let value): try encodeSingleValue(value)
        case .uint8(let value): try encodeSingleValue(value)
        case .uint16(let value): try encodeSingleValue(value)
        case .uint32(let value): try encodeSingleValue(value)
        case .uint64(let value): try encodeSingleValue(value)
        case .double(let value): try encodeSingleValue(value)
        case .data(let value): try encodeSingleValue(value)
        case .date(let value): try encodeSingleValue(value)
        case .string(let value): try encodeSingleValue(value)
        }
    }

    var value: Any? {
        switch self {
        case .dictionary(let value): return value.mapValues { $0.value }
        case .array(let value): return value.map { $0.value }
        case .nil: return nil
        case .bool(let value): return value
        case .int(let value): return value
        case .int8(let value): return value
        case .int16(let value): return value
        case .int32(let value): return value
        case .int64(let value): return value
        case .uint(let value): return value
        case .uint8(let value): return value
        case .uint16(let value): return value
        case .uint32(let value): return value
        case .uint64(let value): return value
        case .double(let value): return value
        case .data(let value): return value
        case .date(let value): return value
        case .string(let value): return value
        }
    }

    init?(value: Any?) {
        guard let value = value else {
            self = .nil
            return
        }

        if let value = value as? [String: Any] {
            let dict = value.compactMapValues(CodableElement.init)
            guard dict.count == value.count else { return nil }
            self = .dictionary(dict)
            return
        }

        if let value = value as? [Any] {
            let array = value.compactMap(CodableElement.init)
            guard array.count == value.count else { return nil }
            self = .array(array)
            return
        }

        if let value = value as? Bool {
            self = .bool(value)
        } else if let value = value as? Int {
            self = .int(value)
        } else if let value = value as? Int8 {
            self = .int8(value)
        } else if let value = value as? Int16 {
            self = .int16(value)
        } else if let value = value as? Int32 {
            self = .int32(value)
        } else if let value = value as? Int64 {
            self = .int64(value)
        } else if let value = value as? UInt {
            self = .uint(value)
        } else if let value = value as? UInt8 {
            self = .uint8(value)
        } else if let value = value as? UInt16 {
            self = .uint16(value)
        } else if let value = value as? UInt32 {
            self = .uint32(value)
        } else if let value = value as? UInt64 {
            self = .uint64(value)
        } else if let value = value as? Double {
            self = .double(value)
        } else if let value = value as? Data {
            self = .data(value)
        } else if let value = value as? Date {
            self = .date(value)
        } else if let value = value as? String {
            self = .string(value)
        } else {
            return nil
        }
    }
}
