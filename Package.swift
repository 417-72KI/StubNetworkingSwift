// swift-tools-version: 5.9
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
    #if compiler(<6.0)
        package.dependencies.append(contentsOf: [
            .package(url: "https://github.com/apple/swift-testing", exact: "0.3.0"),
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

// MARK: - Upcoming feature flags for Swift 6
package.targets.forEach {
    $0.swiftSettings = [
        // .forwardTrailingClosures,
        .existentialAny,
        .bareSlashRegexLiterals,
        .conciseMagicFile,
        .importObjcForwardDeclarations,
        .disableOutwardActorInference,
        .deprecateApplicationMain,
        .isolatedDefaultValues,
        .globalConcurrency,
    ]
}

// ref: https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
private extension SwiftSetting {
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")              // SE-0286, Swift 5.3,  SwiftPM 5.8+
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")                // SE-0354, Swift 5.7,  SwiftPM 5.8+
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")                            // SE-0274, Swift 5.8,  SwiftPM 5.8+
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")  // SE-0384, Swift 5.9,  SwiftPM 5.9+
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")    // SE-0401, Swift 5.9,  SwiftPM 5.9+
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")            // SE-0383, Swift 5.10, SwiftPM 5.10+
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")                  // SE-0411, Swift 5.10, SwiftPM 5.10+
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")                          // SE-0412, Swift 5.10, SwiftPM 5.10+
}

// MARK: - Enabling Complete Concurrency Checking for Swift 6
// ref: https://www.swift.org/documentation/concurrency/
package.targets.forEach {
    var settings = $0.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency"))
    $0.swiftSettings = settings
}
