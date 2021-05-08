// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SuperchargeCore",
    platforms: [
        .iOS("13.0"),
        .macOS("10.11")
    ],
    products: [
        .library(
            name: "Superutils",
            type: .dynamic,
            targets: ["Superutils"]
        ),
        .library(
            name: "ProtoCodable",
            type: .dynamic,
            targets: ["ProtoCodable"]
        ),
        .library(
            name: "SignerSupport",
            type: .dynamic,
            targets: ["SignerSupport"]
        ),
    ],
    targets: [
        .target(name: "ProtoCodable"),
        .target(name: "Superutils"),
        .target(name: "SignerSupport"),
    ]
)

#if os(Linux) || os(Windows)
package.products += [
    .library(name: "plist", targets: ["plistSystem"]),
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
        name: "libimobiledeviceSystem",
        pkgConfig: "libimobiledevice-1.0",
        providers: [
            .apt(["libimobiledevice-dev"])
        ]
    )
]
#else
// the wrapper targets merely add a level of indirection, which seems to
// resolve Xcode bugs for some bizarre reason.

package.products += [
    .library(name: "plist", targets: ["plist"]),
    .library(name: "usbmuxd", targets: ["usbmuxd"]),
    .library(name: "libimobiledevice", targets: ["libimobiledevice"]),
    .library(name: "OpenSSL", targets: ["OpenSSL"]),
]
package.targets += [
    .binaryTarget(name: "plist", path: "vendored/plist.xcframework"),
    .binaryTarget(name: "usbmuxd", path: "vendored/usbmuxd.xcframework"),
    .binaryTarget(name: "libimobiledevice", path: "vendored/libimobiledevice.xcframework"),
    .binaryTarget(name: "OpenSSL", path: "vendored/OpenSSL.xcframework"),
]

#endif
