// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CircuitBreakerTime",
    products: [
        .executable(
            name: "CircuitBreakerTime",
            targets: ["CircuitBreakerTime"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/CircuitBreaker.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/eman6576/SGCircuitBreaker.git", .upToNextMajor(from: "1.1.2")),
        .package(url: "https://github.com/IBM-Swift/Kitura.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMajor(from: "1.7.1"))
    ],
    targets: [
        .target(
            name: "CircuitBreakerTime",
            dependencies: ["CircuitBreakerTimeLib"],
            path: "./Sources/CircuitBreakerTime/"
        ),
        .target(
            name: "CircuitBreakerTimeLib",
            dependencies: [
                "Kitura",
                "HeliumLogger",
                "SGCircuitBreaker",
                "CircuitBreaker"
            ],
            path: "./Sources/CircuitBreakerTimeLib/"
        )
    ]
)
