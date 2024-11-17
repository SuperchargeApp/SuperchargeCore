// swift-tools-version:5.10

import PackageDescription

extension Product.Library.LibraryType {
    static var smart: Self {
        #if os(Linux)
        return .static
        #else
        return .dynamic
        #endif
    }
}

let package = Package(
    name: "SuperchargeCore",
    platforms: [
        .iOS("14.0"),
        .macOS("11.0"),
    ],
    products: [
        .library(
            name: "Superutils",
            type: .smart,
            targets: ["Superutils"]
        ),
        .library(
            name: "SuperutilsTestSupport",
            type: .smart,
            targets: ["SuperutilsTestSupport"]
        ),
        .library(
            name: "ProtoCodable",
            type: .smart,
            targets: ["ProtoCodable"]
        ),
        .library(
            name: "SignerSupport",
            type: .smart,
            targets: ["SignerSupport"]
        ),
        .library(name: "plist", targets: ["plist"]),
        .library(name: "libimobiledeviceGlue", targets: ["libimobiledeviceGlue"]),
        .library(name: "usbmuxd", targets: ["usbmuxd"]),
        .library(name: "libimobiledevice", targets: ["libimobiledevice"]),
        .library(name: "OpenSSL", targets: ["OpenSSL"]),
    ],
    targets: [
        .target(name: "ProtoCodable"),
        .target(name: "Superutils"),
        .target(name: "SignerSupport"),
        .target(name: "SuperutilsTestSupport"),
        .testTarget(
            name: "ProtoCodableTests",
            dependencies: ["ProtoCodable", "SuperutilsTestSupport"]
        ),
    ]
)

#if os(Linux) || os(Windows)
package.targets += [
    .systemLibrary(
        name: "OpenSSL",
        path: "Sources/OpenSSLSystem",
        pkgConfig: "openssl",
        providers: [
            .apt(["libssl-dev"])
        ]
    ),
    .systemLibrary(
        name: "plist",
        path: "Sources/plistSystem",
        pkgConfig: "libplist-2.0",
        providers: [
            .apt(["libplist-dev"])
        ]
    ),
    .systemLibrary(
        name: "usbmuxd",
        path: "Sources/usbmuxdSystem",
        pkgConfig: "libusbmuxd-2.0",
        providers: [
            .apt(["libusbmuxd-dev"])
        ]
    ),
    .systemLibrary(
        name: "libimobiledeviceGlue",
        path: "Sources/libimobiledeviceGlueSystem",
        pkgConfig: "libimobiledevice-glue-1.0",
        providers: [
            .apt(["libimobiledevice-dev"])
        ]
    ),
    .systemLibrary(
        name: "libimobiledevice",
        path: "Sources/libimobiledeviceSystem",
        pkgConfig: "libimobiledevice-1.0",
        providers: [
            .apt(["libimobiledevice-dev"])
        ]
    ),
]
#else
package.targets += [
    .binaryTarget(name: "plist", path: "vendored/plist.xcframework"),
    .binaryTarget(name: "libimobiledeviceGlue", path: "vendored/libimobiledeviceGlue.xcframework"),
    .binaryTarget(name: "usbmuxd", path: "vendored/usbmuxd.xcframework"),
    .binaryTarget(name: "libimobiledevice", path: "vendored/libimobiledevice.xcframework"),
    .binaryTarget(name: "OpenSSL", path: "vendored/OpenSSL.xcframework"),
]
#endif
