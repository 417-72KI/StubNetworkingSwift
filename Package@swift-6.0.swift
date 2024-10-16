// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let isDevelop = true

let isObjcAvailable: Bool = {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    return true
    #else
    return false
    #endif
}()

let package = Package(
    name: "StubNetworkKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "StubNetworkKit",
            targets: ["StubNetworkKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/417-72KI/MultipartFormDataParser.git", from: "2.3.1")
    ],
    targets: [
        .target(
            name: "StubNetworkKit",
            dependencies: ["MultipartFormDataParser"]
        ),
    ]
)

if isDevelop {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
    ])
    if isObjcAvailable {
        package.dependencies.append(contentsOf: [
            .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.57.0"),
            .package(url: "https://github.com/ishkawa/APIKit.git", from: "5.4.0"),
        ])
    }

    let testTarget = Target.testTarget(
        name: "StubNetworkKitTests",
        dependencies: [
            "StubNetworkKit",
            "Alamofire",
        ],
        resources: [.copy("_Fixtures")]
    )
    if isObjcAvailable {
        testTarget.dependencies.append(contentsOf: [
            "APIKit",
        ])
    }
    #if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS)) && !SWIFT_PM_SUPPORTS_SWIFT_TESTING
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/swiftlang/swift-testing", revision: "swift-6.0-RELEASE"),
    ])
    testTarget.dependencies.append(contentsOf: [
        .product(name: "Testing", package: "swift-testing"),
    ])
    #endif
    package.targets.append(testTarget)

    if isObjcAvailable {
        package.targets.forEach {
            $0.dependencies.append(contentsOf: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
            ])
        }
    }
}

// MARK: - Upcoming feature flags for Swift 7
package.targets.forEach {
    $0.swiftSettings = [
        // .forwardTrailingClosures,
        .existentialAny,
    ]
}

// ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
private extension SwiftSetting {
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
}
