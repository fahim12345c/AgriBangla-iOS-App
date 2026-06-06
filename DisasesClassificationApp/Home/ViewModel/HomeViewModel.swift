//
//  HomeViewModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//
import Foundation
import CoreLocation
import Combine

// MARK: - HomeViewModel
@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State
    @Published var weather: WeatherDisplayModel = .placeholder
    @Published var weatherState: WeatherLoadState = .loading
    @Published var userName: String = "Farmer"
    @Published var featureCards: [FeatureCard] = FeatureCard.allCards
    @Published var currentDate: String = ""
    @Published var locationTitle: String = "Current Location"

    // MARK: - Dependencies
    private let weatherService: WeatherService
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        weatherService: WeatherService = .shared,
        locationManager: LocationManager = .shared
    ) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.currentDate = formattedDate()
        observeLocation()
    }

    // MARK: - Public Actions
    func onAppear(userName: String) {
        self.userName = userName
        locationManager.requestLocation()
    }

    func refreshWeather() {
        guard let location = locationManager.location else {
            locationManager.requestLocation()
            return
        }
        Task { await fetchWeather(for: location) }
    }

    // MARK: - Private
    private func observeLocation() {
        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates { a, b in
                a.distance(from: b) < 500 // only re-fetch if moved >500m
            }
            .sink { [weak self] location in
                Task { await self?.fetchWeather(for: location) }
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
            .sink { [weak self] error in
                self?.weatherState = .error(error)
            }
            .store(in: &cancellables)
    }

    private func fetchWeather(for location: CLLocation) async {
        weatherState = .loading
        do {
            let response = try await weatherService.fetchWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
            weather = response.toDisplayModel()
            weatherState = .loaded
        } catch {
            weatherState = .error(error.localizedDescription)
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date())
    }
}

// MARK: - WeatherLoadState
enum WeatherLoadState: Equatable {
    case loading
    case loaded
    case error(String)
}
