// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "SwiftyRoguelike",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "SwiftyRoguelike", targets: ["SwiftyRoguelike"])
    ],
    targets: [
        .executableTarget(
            name: "SwiftyRoguelike",
            path: "Sources/SwiftyRoguelike"
        )
    ]
)
