//
//  SharedExtensions.swift
//  Supercharge
//
//  Created by Kabir Oberai on 30/09/18.
//  Copyright © 2018 Kabir Oberai. All rights reserved.
//

import Foundation

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
        return try url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: documentDirectory, create: true)
    }
    
}
