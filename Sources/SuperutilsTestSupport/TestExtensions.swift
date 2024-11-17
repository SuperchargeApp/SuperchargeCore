import XCTest

public func XCTTry<T>(
    _ block: @autoclosure () throws -> T,
    _ message: String? = nil,
    file: StaticString = #file,
    line: UInt = #line
) rethrows -> T {
    do {
        return try block()
    } catch {
        XCTFail("\(message.map { "\($0)\nError: " } ?? "")\(error)", file: file, line: line)
        throw error
    }
}
