//
//  WeatherViewModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {

    @Published var weather: WeatherDisplayModel?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = WeatherService.shared

    func fetchWeather(lat: Double, lon: Double) async {

        isLoading = true
        errorMessage = nil

        do {
            let response = try await service.fetchWeather(lat: lat, lon: lon)
            weather = response.toDisplayModel()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
