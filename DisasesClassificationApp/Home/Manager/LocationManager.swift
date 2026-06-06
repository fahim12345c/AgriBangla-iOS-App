//
//  LocationManager.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//

//
//  LocationManager.swift
//  AgriAI Dashboard
//

import Foundation
import CoreLocation
import Combine

// MARK: - LocationManager
@MainActor
final class LocationManager: NSObject, ObservableObject {

    static let shared = LocationManager()

    @Published var location: CLLocation? = nil
    @Published var locationName: String? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String? = nil

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.distanceFilter = 1000 // Update every 1km
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Enable in Settings → Privacy → Location."
        @unknown default:
            break
        }
    }

    private func updateLocationName(from location: CLLocation) async {
        guard !geocoder.isGeocoding else { return }
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            let p = placemarks.first
            let parts = [
                p?.locality,
                p?.subAdministrativeArea,
                p?.administrativeArea
            ].compactMap { $0 }.filter { !$0.isEmpty }
            locationName = parts.first ?? p?.name ?? "Current Location"
        } catch {
            // Keep previous value; don't hard-fail UI on reverse-geocode issues.
            if locationName == nil { locationName = "Current Location" }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.location = loc
            self.locationError = nil
            await self.updateLocationName(from: loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error.localizedDescription
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
}
