//
//  TestType.swift
//  ProtoCodableTests
//
//  Created by Kabir Oberai on 06/11/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation
import ProtoCodable

protocol TestType: ProtoCodable {
    var stringValue: String { get }
}

extension TestType {
    static var identifier: String {
        return identifier(withBaseName: "TestType")
    }
}

struct TestTypeContainer: ProtoCodableKeyedTypeContainer {
    var value: TestType
}

extension TestTypeContainer {
    static let supportedTypes: [ProtoCodable.Type] = [
        TestTypeString.self,
        TestTypeInt.self
    ]
}

struct TestTypeString: TestType {
    let name: String

    var stringValue: String { name }
}

struct TestTypeInt: TestType {
    let int: Int

    var stringValue: String { .init(int) }
}
