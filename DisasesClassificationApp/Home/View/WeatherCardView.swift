//
//  WeatherCardView.swift
//  DisasesClassificationApp
//

import SwiftUI

// MARK: - WeatherCardView
struct WeatherCardView: View {
    let locationTitle: String
    let weather: WeatherDisplayModel
    let state: WeatherLoadState
    let onRefresh: () -> Void

    private let farmGreen = Color(red: 0.18, green: 0.49, blue: 0.20)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.18, green: 0.55, blue: 0.20),
                            Color(red: 0.10, green: 0.38, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: farmGreen.opacity(0.3), radius: 12, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 0) {

                // Top row — location + refresh
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                        Text(locationTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack(spacing: 8) {
                        if case .error = state {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red.opacity(0.9))
                        }
                        Button(action: onRefresh) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }
                .padding(.bottom, 14)

                // Middle row — temp + condition
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 6) {
                        // Simple Bengali + English date label
                        Text(formattedDate())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))

                        Text(weather.description)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)

                        Text(weather.tempRange)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.75))

                        // Simple heat advice for farmer
                        Text(heatAdvice(for: weather.temperature))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.yellow.opacity(0.95))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        if state == .loading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.3)
                                .padding(.trailing, 8)
                        } else {
                            Text(weather.temperature)
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Image(systemName: weather.icon)
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.9))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(.bottom, 14)

                Divider()
                    .background(Color.white.opacity(0.35))
                    .padding(.bottom, 12)

                // Stats row — only 3 things a farmer cares about
                HStack {
                    weatherStat(icon: "humidity.fill",   value: weather.humidity,  label: "আর্দ্রতা\nHumidity")
                    Spacer()
                    weatherStat(icon: "wind",            value: weather.windSpeed, label: "বাতাস\nWind")
                    Spacer()
                    weatherStat(icon: "cloud.rain.fill", value: weather.rain,      label: "বৃষ্টি\nRain")
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stat cell
    private func weatherStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Simple heat advice shown inside the card
    private func heatAdvice(for temperature: String) -> String {
        // Parse the numeric value from e.g. "35°C"
        let digits = temperature.filter { $0.isNumber || $0 == "." }
        let temp = Double(digits) ?? 0
        if temp >= 38 {
            return "⚠️ খুব গরম — সকালে বা বিকালে কাজ করুন\n⚠️ Very hot — work in morning or evening"
        } else if temp >= 32 {
            return "☀️ গরম দিন — পানি পান করুন\n☀️ Hot day — drink water often"
        } else {
            return "✅ কাজের জন্য ভালো আবহাওয়া\n✅ Good weather to work"
        }
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }
}
