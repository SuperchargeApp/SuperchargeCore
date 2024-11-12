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
package.products += [
    .library(name: "plist", targets: ["plistSystem"]),
    .library(name: "libimobiledeviceGlue", targets: ["libimobiledeviceGlueSystem"]),
    .library(name: "usbmuxd", targets: ["usbmuxdSystem"]),
    .library(name: "libimobiledevice", targets: ["libimobiledeviceSystem"]),
    .library(name: "OpenSSL", targets: ["OpenSSLSystem"]),
]
package.targets += [
    .systemLibrary(
        name: "OpenSSLSystem",
        pkgConfig: "openssl",
        providers: [
            .apt(["libssl-dev"])
        ]
    ),
    .systemLibrary(
        name: "plistSystem",
        pkgConfig: "libplist-2.0",
        providers: [
            .apt(["libplist-dev"])
        ]
    ),
    .systemLibrary(
        name: "usbmuxdSystem",
        pkgConfig: "libusbmuxd-2.0",
        providers: [
            .apt(["libusbmuxd-dev"])
        ]
    ),
    .systemLibrary(
        name: "libimobiledeviceGlueSystem",
        pkgConfig: "libimobiledevice-glue-1.0",
        providers: [
            .apt(["libimobiledevice-dev"])
        ]
    ),
    .systemLibrary(
        name: "libimobiledeviceSystem",
        pkgConfig: "libimobiledevice-1.0",
        providers: [
            .apt(["libimobiledevice-dev"])
        ]
    ),
]
#else
package.products += [
    .library(name: "plist", targets: ["plist"]),
    .library(name: "libimobiledeviceGlue", targets: ["libimobiledeviceGlue"]),
    .library(name: "usbmuxd", targets: ["usbmuxd"]),
    .library(name: "libimobiledevice", targets: ["libimobiledevice"]),
    .library(name: "OpenSSL", targets: ["OpenSSL"]),
]
package.targets += [
    .binaryTarget(name: "plist", path: "vendored/plist.xcframework"),
    .binaryTarget(name: "libimobiledeviceGlue", path: "vendored/libimobiledeviceGlue.xcframework"),
    .binaryTarget(name: "usbmuxd", path: "vendored/usbmuxd.xcframework"),
    .binaryTarget(name: "libimobiledevice", path: "vendored/libimobiledevice.xcframework"),
    .binaryTarget(name: "OpenSSL", path: "vendored/OpenSSL.xcframework"),
]
#endif
