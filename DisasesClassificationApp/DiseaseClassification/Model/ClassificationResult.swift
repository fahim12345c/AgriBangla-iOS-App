import Foundation

struct ClassificationResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
}

struct ClassificationOutput {
    let topResults: [ClassificationResult]
    let allLabels: [String]
    let allConfidences: [Float]
}
