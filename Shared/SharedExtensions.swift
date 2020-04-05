//
//  SharedExtensions.swift
//  Supercharge
//
//  Created by Kabir Oberai on 30/09/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

func unimplemented(_ message: String? = nil, function: StaticString = #function,
                   file: StaticString = #file, line: UInt = #line) -> Never {
    var fullMessage = "\(function) has not been implemented"
    if let message = message {
        fullMessage += ". Message: \(message)"
    }
    fatalError(fullMessage, file: file, line: line)
}

func abstract(function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> Never {
    fatalError("\(function) is expected to be implemented by subclasses", file: file, line: line)
}

extension String {

    func subtracting(_ base: String) -> String {
        let afterBase = index(base.endIndex, offsetBy: 1)
        return String(self[afterBase...])
    }

}

extension Progress {

    static func performDiscretely<ReturnType>(work: () throws -> ReturnType) rethrows -> ReturnType {
        return try discreteProgress(totalUnitCount: 1).performAsCurrent(withPendingUnitCount: 1, using: work)
    }

}

extension URL {

    var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    var dirExists: Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    // Contents' order not guaranteed. Should sort when displaying.
    func contents() throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)
    }

    var implicitContents: [URL] {
        return (try? contents()) ?? []
    }

    var filename: String {
        return deletingPathExtension().lastPathComponent
    }

    func uniqueFile(withExtension ext: String = "") -> URL {
        var url: URL
        repeat {
            // just using interpolation leads to "<UUID>." if ext is empty
            url = appendingPathComponent(UUID().uuidString).appendingPathExtension(ext)
        } while url.exists
        return url
    }

    func createDir() throws {
        try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true, attributes: nil)
    }
    
}

extension FileManager {

    static var disallowedFilenameCharacters: CharacterSet {
        .init(charactersIn: ":/")
    }

    func forceCopyItem(atPath srcPath: String, toPath dstPath: String) throws {
        if fileExists(atPath: dstPath) {
            try removeItem(atPath: dstPath)
        }
        try copyItem(atPath: srcPath, toPath: dstPath)
    }

    func forceMoveItem(at srcURL: URL, to dstURL: URL) throws {
        if fileExists(atPath: dstURL.path) {
            try removeItem(at: dstURL)
        }
        try moveItem(at: srcURL, to: dstURL)
    }

    var documentDirectory: URL {
        #if JB
        let url = URL(fileURLWithPath: "/var/mobile/Library/Application Support/Supercharge")
        if !url.dirExists {
            try? url.createDir()
        }
        return url
        #else
        return urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
    }

    func cachesDirectory() throws -> URL {
        #if JB
        return URL(fileURLWithPath: "/var/mobile/Library/Caches/com.kabiroberai.Supercharge")
        #else
        return try url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        #endif
    }

    func makeTemporaryDirectory() throws -> URL {
        return try url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: documentDirectory,
            create: true
        )
    }

}

extension Collection {
    func removingDuplicates(isEqual: (Element, Element) -> Bool) -> [Element] {
        reduce(into: []) { result, curr in
            if !result.contains(where: { isEqual($0, curr) }) {
                result.append(curr)
            }
        }
    }

    func removingDuplicates<T: Equatable>(equatingBy key: (Element) -> T) -> [Element] {
        removingDuplicates { key($0) == key($1) }
    }

    func removingDuplicates<T: Hashable>(hashingBy key: (Element) -> T) -> [Element] {
        var added: Set<T> = []
        return filter { added.insert(key($0)).inserted }
    }
}
extension Collection where Element: Equatable {
    func removingDuplicates() -> [Element] { removingDuplicates { $0 == $1 } }
}
extension Collection where Element: Hashable {
    func removingDuplicates() -> [Element] { removingDuplicates { $0 } }
}

extension RangeReplaceableCollection {
    mutating func removeDuplicates(isEqual: (Element, Element) -> Bool) {
        var added: [Element] = []
        removeAll { curr in
            let exists = added.contains(where: { isEqual($0, curr) })
            if !exists { added.append(curr) }
            return exists
        }
    }

    mutating func removeDuplicates<T: Equatable>(equatingBy key: (Element) -> T) {
        removeDuplicates { key($0) == key($1) }
    }

    mutating func removeDuplicates<T: Hashable>(hashingBy key: (Element) -> T) {
        var added: Set<T> = []
        removeAll { !added.insert(key($0)).inserted }
    }
}
extension RangeReplaceableCollection where Element: Equatable {
    mutating func removeDuplicates() { removeDuplicates { $0 } }
}
extension RangeReplaceableCollection where Element: Hashable {
    mutating func removeDuplicates() { removeDuplicates { $0 } }
}

// https://gist.github.com/NikolaiRuhe/408cefb953c4bea15506a3f80a3e5b96
extension FileManager {

    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    func allocatedSizeOfDirectory(at directoryURL: URL) throws -> UInt64 {

        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }

        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!

        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0

        // Perform the traversal.
        for item in enumerator {

            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { break }

            // Add up individual file sizes.
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
        }

        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }

        return accumulatedSize
    }

}


fileprivate let allocatedSizeResourceKeys: Set<URLResourceKey> = [
    .isRegularFileKey,
    .fileAllocatedSizeKey,
    .totalFileAllocatedSizeKey,
]


fileprivate extension URL {

    func regularFileAllocatedSize() throws -> UInt64 {
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)

        // We only look at regular files.
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }

        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }

}

extension Result {

    func get<T>(withErrorHandler errorHandler: (Result<T, Failure>) -> Void) -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            errorHandler(.failure(error))
            return nil
        }
    }

}

extension Dictionary {

    func recursivelyMerging(_ other: Dictionary) -> Dictionary {
        return merging(other) { old, new in
            if let old = old as? Dictionary,
                let new = new as? Dictionary,
                // https://stackoverflow.com/a/45221496/3769927 (`as? Value`)
                let merged = old.recursivelyMerging(new) as? Value {
                return merged
            }
            return new
        }
    }

}

extension Optional {

    func orThrow(_ error: @autoclosure () -> Error) throws -> Wrapped {
        guard let wrapped = self else { throw error() }
        return wrapped
    }

}
