import Foundation

enum ApplicationType: String, CaseIterable, Identifiable {
    case herbicide = "Herbicide"
    case fungicide = "Fungicide"
    case insecticide = "Insecticide"

    var id: String { rawValue }
}

enum SprayingWindowStatus: String {
    case optimal = "Optimal"
    case marginal = "Marginal"
    case poor = "Poor"
}

struct SprayingAssessment: Equatable {
    let status: SprayingWindowStatus
    let deltaT: Double
    let windKmh: Double
    let summaryLines: [SprayingSummaryLine]
    let adviceTitle: String
    let adviceBody: String
}

struct SprayingSummaryLine: Identifiable, Equatable {
    enum Level: Equatable {
        case good
        case bad
        case info
    }

    let id = UUID()
    let level: Level
    let text: String
}

struct HourSlot: Identifiable, Equatable {
    let id = UUID()
    let timeLabel: String
    let icon: String
    let tempC: Int
    let windKmh: Int
    let deltaT: Double
    let status: SprayingWindowStatus
}

