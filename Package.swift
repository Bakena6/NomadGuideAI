// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NomadGuideAI",
    platforms: [
        .iOS(.v17),  // MLX requires iOS 17+
    ],
    products: [
        .app(
            name: "NomadGuideAI",
            targets: ["NomadGuideAI"]
        ),
    ],
    dependencies: [
        // MLX Swift — Apple Silicon machine learning framework
        .package(url: "https://github.com/ml-explore/mlx-swift.git",
                 .upToNextMinor(from: "0.31.3")),
        // swift-transformers — HuggingFace tokenizer & model loading
        .package(url: "https://github.com/huggingface/swift-transformers.git",
                 .upToNextMajor(from: "1.3.0")),
    ],
    targets: [
        // Main app target
        .target(
            name: "NomadGuideAI",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXNN", package: "mlx-swift"),
                .product(name: "MLXFast", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
                .product(name: "Transformers", package: "swift-transformers"),
            ],
            path: "Sources",
            resources: [
                // Knowledge base index will be bundled here
                .copy("Resources/faiss_index.bin"),
                .copy("Resources/chunks.jsonl"),
                .copy("Resources/embedding_model.mlpackage"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
