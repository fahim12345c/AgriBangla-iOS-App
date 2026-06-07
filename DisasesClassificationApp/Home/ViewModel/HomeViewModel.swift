import Foundation
import CoreLocation
import Combine
import UIKit
import FirebaseAuth

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var weather: WeatherDisplayModel = .placeholder
    @Published var weatherState: WeatherLoadState = .loading
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var profileImageURL: String?
    @Published var profileUploadError: String?
    @Published var isUploadingProfileImage = false
    @Published var featureCards: [FeatureCard] = FeatureCard.allCards
    @Published var currentDate: String = ""
    @Published var locationTitle: String = "Current Location"

    private let weatherService: WeatherService
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

    init(
        weatherService: WeatherService = .shared,
        locationManager: LocationManager = .shared
    ) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        self.currentDate = formattedDate()
        observeLocation()
    }

    func onAppear(userName: String) {
        self.userName = userName
        locationManager.requestLocation()
        fetchUserProfile()
    }

    func refreshWeather() {
        guard let location = locationManager.location else {
            locationManager.requestLocation()
            return
        }
        Task { await fetchWeather(for: location) }
    }

    func uploadProfileImageData(_ data: Data) {
        profileUploadError = nil
        isUploadingProfileImage = true
        print("[ProfileUpload] Starting upload, data size: \(data.count) bytes")
        Task {
            do {
                print("[ProfileUpload] Creating UIImage from data...")
                guard let uiImage = UIImage(data: data) else {
                    print("[ProfileUpload] FAILED: UIImage(data:) returned nil")
                    throw ProfileImageError.loadFailed("The selected file is not a valid image format.")
                }
                print("[ProfileUpload] UIImage created: \(uiImage.size.width)x\(uiImage.size.height)")
                print("[ProfileUpload] Calling CloudinaryService.uploadImage...")
                let url = try await CloudinaryService.shared.uploadImage(uiImage)
                print("[ProfileUpload] Cloudinary upload succeeded, URL: \(url)")
                guard let userId = Auth.auth().currentUser?.uid else {
                    print("[ProfileUpload] FAILED: No authenticated user")
                    throw ProfileImageError.loadFailed("User session not found. Please sign in again.")
                }
                print("[ProfileUpload] Saving URL to Firestore for user: \(userId)")
                try await FirestoreManager.shared.updateProfileImageURL(userId: userId, url: url)
                print("[ProfileUpload] Firestore save succeeded")
                profileImageURL = url
                isUploadingProfileImage = false
                print("[ProfileUpload] SUCCESS - profile image updated")
            } catch {
                print("[ProfileUpload] ERROR: \(error.localizedDescription)")
                profileUploadError = error.localizedDescription
                isUploadingProfileImage = false
            }
        }
    }

    private func fetchUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Task {
            if let user = try? await FirestoreManager.shared.fetchUser(userId: userId) {
                let first = user.firstName ?? ""
                let last = user.lastName ?? ""
                userName = [first, last].filter { !$0.isEmpty }.joined(separator: " ")
                userEmail = user.email
                profileImageURL = user.profileImageURL
            } else {
                userName = Auth.auth().currentUser?.displayName ?? "User"
                userEmail = Auth.auth().currentUser?.email ?? ""
            }
        }
    }

    private func observeLocation() {
        locationManager.$location
            .compactMap { $0 }
            .removeDuplicates { a, b in a.distance(from: b) < 500 }
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

enum ProfileImageError: LocalizedError {
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .loadFailed(let message):
            return message
        }
    }
}

enum WeatherLoadState: Equatable {
    case loading
    case loaded
    case error(String)
}
