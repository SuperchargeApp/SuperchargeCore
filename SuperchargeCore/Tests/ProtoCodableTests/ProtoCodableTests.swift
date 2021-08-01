//
//  ProtoCodableTests.swift
//  ProtoCodableTests
//
//  Created by Kabir Oberai on 06/11/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import XCTest
import SuperutilsTestSupport

class ProtoCodableTests: XCTestCase {

    private var encoder: JSONEncoder!
    private var decoder: JSONDecoder!

    private let myName = "Kabir"
    private lazy var encoded = """
    {"type":"String","name":"\(myName)"}
    """

    override func setUp() {
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    override func tearDown() {
        encoder = nil
        decoder = nil
    }

    func testBasicEncoding() throws {
        let name = "Kabir"
        let original = TestTypeString(name: name)
        let container = TestTypeContainer(value: original)

        let data = try XCTTry(encoder.encode(container), "Could not encode container")
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, encoded)
    }

    func testBasicDecoding() throws {
        let data = encoded.data(using: .utf8)!
        let decodedContainer = try XCTTry(decoder.decode(TestTypeContainer.self, from: data), "Could not decode container")
        let decoded = try XCTUnwrap(decodedContainer.value as? TestTypeString)
        XCTAssertEqual(decoded.name, myName)
    }

}
