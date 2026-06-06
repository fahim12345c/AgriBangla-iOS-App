import SwiftUI
import Foundation
import CoreLocation
import Combine

@MainActor
final class WeatherFeatureViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case spraying = "Spraying"
        case details = "Details"
        var id: String { rawValue }
    }

    @Published var mode: Mode = .spraying
    @Published var application: ApplicationType = .herbicide

    @Published var locationTitle: String = "Current Location"
    @Published var temperatureText: String = "--°C"
    @Published var conditionText: String = "--"
    @Published var descriptionText: String = "--"
    @Published var icon: String = "cloud.fill"

    @Published var feelsLikeText: String = "--°C"
    @Published var humidityText: String = "--%"
    @Published var windText: String = "-- km/h"
    @Published var pressureText: String = "-- hPa"
    @Published var cloudsText: String = "--%"
    @Published var rainText: String = "-- mm"

    @Published var assessment: SprayingAssessment = .init(
        status: .marginal,
        deltaT: 0,
        windKmh: 0,
        summaryLines: [],
        adviceTitle: "--",
        adviceBody: "--"
    )
    @Published var next24h: [HourSlot] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let weatherService: WeatherService
    private let locationManager: LocationManager
    private let calculator: SprayingCalculating
    private var cancellables = Set<AnyCancellable>()

    private var latestTempC: Double?
    private var latestHumidity: Double?
    private var latestWindKmh: Double?
    private var latestFeelsLikeC: Double?
    private var latestPressureHPa: Int?
    private var latestCloudsPct: Int?
    private var latestRainMm: Double?

    init(
        weatherService: WeatherService,
        locationManager: LocationManager,
        calculator: SprayingCalculating
    ) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.calculator = calculator
        observeLocation()
    }

    convenience init() {
        self.init(
            weatherService: .shared,
            locationManager: .shared,
            calculator: SprayingCalculator()
        )
    }

    func onAppear() {
        locationManager.requestLocation()
    }

    func refresh() {
        guard let location = locationManager.location else {
            locationManager.requestLocation()
            return
        }
        Task { await fetchWeather(for: location) }
    }

    func showLegend() -> Bool {
        true
    }
    
    var farmerHeatAdvice: String {
        guard let feels = latestFeelsLikeC else { return "" }
        if feels >= 38 {
            return "⚠️ খুব গরম — সকালে বা বিকালে কাজ করুন"
        } else if feels >= 32 {
            return "☀️ গরম দিন — পানি পান করুন"
        } else {
            return "✅ কাজের জন্য ভালো আবহাওয়া"
        }
    }

    var farmerHeatAdviceColor: Color {
        guard let feels = latestFeelsLikeC else { return .secondary }
        if feels >= 38 { return .red }
        if feels >= 32 { return .orange }
        return .green
    }

    // MARK: - Private
    private func observeLocation() {
        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates { a, b in a.distance(from: b) < 500 }
            .sink { [weak self] loc in
                guard let self else { return }
                Task { await self.fetchWeather(for: loc) }
            }
            .store(in: &cancellables)

        locationManager.$locationName
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] name in
                self?.locationTitle = name
            }
            .store(in: &cancellables)

        locationManager.$locationError
            .compactMap { $0 }
            .sink { [weak self] err in
                self?.errorMessage = err
            }
            .store(in: &cancellables)

        $application
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.recomputeDerived()
            }
            .store(in: &cancellables)
    }

    private func fetchWeather(for location: CLLocation) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let res = try await weatherService.fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)

            let tempC = normalizeTempC(res.main.temp)
            let feelsC = normalizeTempC(res.main.feelsLike)
            let humidity = Double(res.main.humidity)
            let windKmh = res.wind.speed * 3.6
            let pressure = res.main.pressure
            let clouds = res.clouds.all
            let rainMm = res.rain?.oneHour ?? 0.0

            latestTempC = tempC
            latestFeelsLikeC = feelsC
            latestHumidity = humidity
            latestWindKmh = windKmh
            latestPressureHPa = pressure
            latestCloudsPct = clouds
            latestRainMm = rainMm

            temperatureText = "\(Int(round(tempC)))°C"
            feelsLikeText = "\(Int(round(feelsC)))°C"
            humidityText = "\(Int(round(humidity)))%"
            windText = "\(Int(round(windKmh))) km/h"
            pressureText = "\(pressure) hPa"
            cloudsText = "\(clouds)%"
            rainText = String(format: "%.1f mm", rainMm)

            let main = res.weather.first?.main ?? "—"
            conditionText = farmerFriendlyCondition(main)
            descriptionText = farmerFriendlyDescription(res.weather.first?.description)
            icon = farmerFriendlyIcon(main: main, iconCode: res.weather.first?.icon)

            recomputeDerived()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func recomputeDerived() {
        guard
            let t = latestTempC,
            let h = latestHumidity,
            let w = latestWindKmh
        else {
            return
        }

        assessment = calculator.assess(tempC: t, humidityPct: h, windKmh: w, application: application)
        // Avoid showing synthetic data in the UI.
        next24h = []
    }

    // MARK: - Normalization & farmer-friendly labels
    /// Some providers return Kelvin even when units=metric is passed.
    private func normalizeTempC(_ raw: Double) -> Double {
        // If it's clearly Kelvin (e.g. 302.14), convert.
        if raw > 170 { return raw - 273.15 }
        return raw
    }

    private func farmerFriendlyCondition(_ main: String) -> String {
        switch main.lowercased() {
        case "haze": return "HAZY"
        case "mist": return "MIST"
        case "fog": return "FOG"
        case "smoke": return "SMOKE"
        case "dust", "sand": return "DUSTY"
        case "clear": return "CLEAR"
        case "clouds": return "CLOUDY"
        case "rain", "drizzle": return "RAIN"
        case "thunderstorm": return "STORM"
        case "snow": return "SNOW"
        default: return main.uppercased()
        }
    }

    private func farmerFriendlyDescription(_ desc: String?) -> String {
        guard let d = desc?.trimmingCharacters(in: .whitespacesAndNewlines), !d.isEmpty else { return "—" }
        return d.capitalized
    }

    private func farmerFriendlyIcon(main: String, iconCode: String?) -> String {
        // Prefer your existing SF mapping when possible.
        // iconCode from provider: "50n" etc.
        if let code = iconCode {
            switch code {
            case "01d": return "sun.max.fill"
            case "01n": return "moon.stars.fill"
            case "02d", "02n": return "cloud.sun.fill"
            case "03d", "03n", "04d", "04n": return "cloud.fill"
            case "09d", "09n": return "cloud.drizzle.fill"
            case "10d": return "cloud.sun.rain.fill"
            case "10n": return "cloud.moon.rain.fill"
            case "11d", "11n": return "cloud.bolt.rain.fill"
            case "13d", "13n": return "snowflake"
            case "50d", "50n": return "cloud.fog.fill"
            default: break
            }
        }

        // Fallback by main.
        switch main.lowercased() {
        case "haze", "mist", "fog": return "cloud.fog.fill"
        case "clear": return "sun.max.fill"
        case "clouds": return "cloud.fill"
        case "rain", "drizzle": return "cloud.rain.fill"
        case "thunderstorm": return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}

