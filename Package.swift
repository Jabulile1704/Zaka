// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ZakaLogic",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "ZakaLogic",
            path: "Zaka/Support",
            exclude: [
                "AmbientBackground.swift",
                "CSVExport.swift",
                "CoinPalette.swift",
                "DayGroup.swift"
            ],
            sources: ["EAN13.swift", "Money.swift"]
        ),
        .testTarget(
            name: "ZakaLogicTests",
            dependencies: ["ZakaLogic"],
            path: "Tests/ZakaLogicTests"
        )
    ]
)
