import Foundation

protocol SprayingCalculating {
    func assess(tempC: Double, humidityPct: Double, windKmh: Double, application: ApplicationType) -> SprayingAssessment
    func next24hSlots(now: Date, baseTempC: Double, baseHumidityPct: Double, baseWindKmh: Double, application: ApplicationType) -> [HourSlot]
}

/// A lightweight, deterministic calculator to support UI/UX.
/// Keeps business logic out of views and avoids network dependencies.
struct SprayingCalculator: SprayingCalculating {
    func assess(tempC: Double, humidityPct: Double, windKmh: Double, application: ApplicationType) -> SprayingAssessment {
        let clampedRH = max(1, min(100, humidityPct))
        let wetBulb = approximateWetBulbC(tempC: tempC, rh: clampedRH)
        let deltaT = max(0, tempC - wetBulb)

        let status = windowStatus(deltaT: deltaT, windKmh: windKmh, application: application, tempC: tempC)
        let lines = summaryLines(deltaT: deltaT, windKmh: windKmh, tempC: tempC, status: status)
        let advice = smartAdvice(deltaT: deltaT, windKmh: windKmh, tempC: tempC, status: status, application: application)

        return SprayingAssessment(
            status: status,
            deltaT: deltaT,
            windKmh: windKmh,
            summaryLines: lines,
            adviceTitle: advice.title,
            adviceBody: advice.body
        )
    }

    func next24hSlots(now: Date, baseTempC: Double, baseHumidityPct: Double, baseWindKmh: Double, application: ApplicationType) -> [HourSlot] {
        let cal = Calendar.current
        // show 4 tiles like the screenshot (now + next 3)
        let hours: [Int] = [0, 1, 2, 3].compactMap { $0 }

        return hours.map { offset in
            let date = cal.date(byAdding: .hour, value: offset, to: now) ?? now
            let label: String = offset == 0 ? "now" : timeLabel(date)

            // small deterministic variation so the UI looks alive
            let temp = baseTempC + Double(offset) * 0.3 - 0.2
            let rh = max(10, min(100, baseHumidityPct - Double(offset) * 1.2))
            let wind = max(0, baseWindKmh + Double(offset) * 0.6 - 0.4)

            let assessment = assess(tempC: temp, humidityPct: rh, windKmh: wind, application: application)

            return HourSlot(
                timeLabel: label,
                icon: iconForStatus(assessment.status),
                tempC: Int(round(temp)),
                windKmh: Int(round(wind)),
                deltaT: assessment.deltaT,
                status: assessment.status
            )
        }
    }

    // MARK: - Window status logic
    private func windowStatus(deltaT: Double, windKmh: Double, application: ApplicationType, tempC: Double) -> SprayingWindowStatus {
        // general constraints
        if windKmh > 18 { return .poor }
        if tempC >= 36 { return .poor }

        // deltaT rule of thumb: 2-8 optimal; >8 too evaporative; <2 runoff risk
        if deltaT < 2 { return .marginal }
        if deltaT > 10 { return .poor }

        // application tweaks
        switch application {
        case .herbicide:
            if windKmh > 12 { return .marginal }
        case .fungicide:
            if deltaT > 8 { return .marginal }
        case .insecticide:
            if windKmh > 15 { return .marginal }
        }

        return (deltaT <= 8) ? .optimal : .marginal
    }

    private func summaryLines(deltaT: Double, windKmh: Double, tempC: Double, status: SprayingWindowStatus) -> [SprayingSummaryLine] {
        var lines: [SprayingSummaryLine] = []

        if tempC >= 33 {
            lines.append(.init(level: .bad, text: "Temp (\(tempC.round1)°C): Too Hot"))
        } else {
            lines.append(.init(level: .good, text: "Temp (\(tempC.round1)°C): Ideal"))
        }

        if windKmh <= 15 {
            lines.append(.init(level: .good, text: "Wind (\(windKmh.round1) km/h): Ideal"))
        } else {
            lines.append(.init(level: .bad, text: "Wind (\(windKmh.round1) km/h): Too Windy"))
        }

        if deltaT >= 2, deltaT <= 8 {
            lines.append(.init(level: .good, text: "Delta T (\(deltaT.round1)°C): Ideal"))
        } else if deltaT > 8 {
            lines.append(.init(level: .bad, text: "Delta T (\(deltaT.round1)°C): Too Dry"))
        } else {
            lines.append(.init(level: .bad, text: "Delta T (\(deltaT.round1)°C): Runoff Risk"))
        }

        let rainRisk = (status == .poor) ? "Medium" : "Low"
        lines.append(.init(level: .info, text: "Rain Risk: \(rainRisk)"))

        return lines
    }

    private func smartAdvice(deltaT: Double, windKmh: Double, tempC: Double, status: SprayingWindowStatus, application: ApplicationType) -> (title: String, body: String) {
        if deltaT > 8 {
            return ("High Evaporation Rate (Delta T > 8)", "Droplets may dry too fast. Increase droplet size and water volume, or spray earlier/later when Delta T is lower.")
        }
        if deltaT < 2 {
            return ("Runoff Risk (Delta T < 2)", "Conditions are humid. Consider reducing volume, increasing travel speed, or waiting for a drier window.")
        }
        if windKmh > 15 {
            return ("Wind Drift Risk", "Wind is high. Avoid fine droplets and consider delaying to reduce drift.")
        }
        if tempC >= 33 {
            return ("Heat Stress Risk", "Temperature is high. Prefer early morning/late afternoon for safer application.")
        }
        switch application {
        case .herbicide:
            return ("Herbicide Window", "Keep wind low to reduce drift. Use coarse droplets when possible.")
        case .fungicide:
            return ("Fungicide Coverage", "Aim for steady wind and moderate Delta T to maximize canopy coverage.")
        case .insecticide:
            return ("Insecticide Timing", "Target calm periods to improve deposition on leaf surfaces.")
        }
    }

    // MARK: - Helpers
    private func timeLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func iconForStatus(_ status: SprayingWindowStatus) -> String {
        switch status {
        case .optimal: return "checkmark.seal.fill"
        case .marginal: return "exclamationmark.triangle.fill"
        case .poor: return "xmark.octagon.fill"
        }
    }

    /// Stull (2011) approximation for wet-bulb temperature (°C).
    private func approximateWetBulbC(tempC: Double, rh: Double) -> Double {
        let t = tempC
        let r = rh
        let tw = t * atan(0.151977 * pow(r + 8.313659, 0.5))
        + atan(t + r)
        - atan(r - 1.676331)
        + 0.00391838 * pow(r, 1.5) * atan(0.023101 * r)
        - 4.686035
        return tw
    }
}

private extension Double {
    var round1: String { String(format: "%.1f", self) }
}

