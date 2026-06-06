import Foundation

// MARK: - API Response
struct WeatherResponse: Codable {
    let dt: Int
    let weather: [WeatherCondition]
    let main: WeatherMain
    let wind: WeatherWind
    let rain: WeatherRain?
    let clouds: WeatherClouds
}

// MARK: - Main
struct WeatherMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin   = "temp_min"
        case tempMax   = "temp_max"
        case pressure
        case humidity
    }
}

// MARK: - Weather Condition
struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Wind
struct WeatherWind: Codable {
    let speed: Double
    let deg: Int
}

// MARK: - Rain
struct WeatherRain: Codable {
    let oneHour: Double?
    
    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

// MARK: - Clouds
struct WeatherClouds: Codable {
    let all: Int
}


extension WeatherResponse {
    
    func toDisplayModel() -> WeatherDisplayModel {
        // ✅ No conversion needed — units=metric gives Celsius directly
        let tempC    = Int(main.temp)
        let minC     = Int(main.tempMin)
        let maxC     = Int(main.tempMax)

        let iconCode = weather.first?.icon ?? "01d"
        let desc     = weather.first?.description.capitalized ?? "Clear"
        let rainValue = rain?.oneHour ?? 0.0

        return WeatherDisplayModel(
            temperature: "\(tempC)°C",
            tempRange: "\(minC)°C / \(maxC)°C",
            description: desc,
            humidity: "\(main.humidity)%",
            windSpeed: "\(Int(wind.speed * 3.6)) km/h",
            rain: String(format: "%.1f mm", rainValue),
            icon: sfSymbol(for: iconCode),
            backgroundColors: []
        )
    }
    
    // MARK: - Icon Mapper
    private func sfSymbol(for icon: String) -> String {
        switch icon {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d", "02n": return "cloud.sun.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "cloud.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snowflake"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    // MARK: - Gradient Mapper
    private func gradientColors(for icon: String) -> [String] {
        if icon.hasPrefix("01") { return ["sunnyStart", "sunnyEnd"] }
        if icon.hasPrefix("09") || icon.hasPrefix("10") || icon.hasPrefix("11") {
            return ["rainyStart", "rainyEnd"]
        }
        if icon.hasPrefix("13") { return ["snowyStart", "snowyEnd"] }
        return ["cloudyStart", "cloudyEnd"]
    }
}
