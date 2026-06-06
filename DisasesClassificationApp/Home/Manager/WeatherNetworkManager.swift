//
//  WeatherNetworkManager.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//

import Foundation

enum WeatherError: LocalizedError {

    case invalidURL
    case serverError
    case decodingError
    case invalidAPIKey
    case locationDenied
    case locationUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL."

        case .serverError:
            return "Weather server error."

        case .decodingError:
            return "Failed to parse weather data."

        case .invalidAPIKey:
            return "Invalid API key. Please check your OpenWeather account."

        case .locationDenied:
            return "Location permission denied."

        case .locationUnavailable:
            return "Unable to get location."
        }
    }
}

final class WeatherService {

    static let shared = WeatherService()
    private init() {}

    private let apiKey = "a62841a8823265c1bff287131c7e13f3"
    private let baseURL = "https://api.agromonitoring.com/agro/1.0/weather"

    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
            let urlString = "\(baseURL)?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"

            guard let url = URL(string: urlString) else {
                throw WeatherError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw WeatherError.serverError
            }

            return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
