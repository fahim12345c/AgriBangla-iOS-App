import SwiftUI
import Combine
import UIKit
import AVFoundation

enum ImageSource: Identifiable {
    case camera
    case photoLibrary
    var id: Self { self }
}

@MainActor
final class DiseaseClassificationViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var result: ClassificationOutput?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showCamera = false
    @Published var showPhotoPicker = false
    @Published var showImageSourcePicker = false
    @Published var hasCameraPermission: Bool? = nil
    @Published var isModelLoaded = false

    @Published var reportText: String?
    @Published var isGeneratingReport = false
    @Published var reportError: String?

    private let classifier: TFLiteService
    private let reportService: DiseaseReportService

    init(classifier: TFLiteService = .shared, reportService: DiseaseReportService = .shared) {
        self.classifier = classifier
        self.reportService = reportService
    }

    func loadModel() {
        Task {
            do {
                try classifier.load()
                isModelLoaded = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasCameraPermission = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                hasCameraPermission = granted
            }
        case .denied, .restricted:
            hasCameraPermission = false
        @unknown default:
            hasCameraPermission = false
        }
    }

    func selectImage(_ image: UIImage) {
        selectedImage = image
        classifyImage(image)
    }

    func classifyImage(_ image: UIImage) {
        guard isModelLoaded else {
            errorMessage = "Model not loaded yet."
            return
        }
        isLoading = true
        errorMessage = nil
        reportText = nil
        reportError = nil
        Task {
            do {
                let output = try classifier.classify(image)
                result = output
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func generateReport() {
        guard let result, let top = result.topResults.first else { return }
        isGeneratingReport = true
        reportError = nil
        reportText = nil

        Task {
            do {
                let text = try await reportService.generateReport(
                    diseaseName: top.label,
                    confidence: top.confidence
                )
                reportText = text
            } catch {
                reportError = error.localizedDescription
            }
            isGeneratingReport = false
        }
    }

    func generatePDF() -> Data? {
        guard let result, let top = result.topResults.first, let text = reportText else { return nil }
        let content = PDFContent(
            diseaseName: top.label,
            confidence: top.confidence,
            reportText: text,
            image: selectedImage
        )
        return PDFGenerator.generate(data: content)
    }

    func reset() {
        selectedImage = nil
        result = nil
        errorMessage = nil
        reportText = nil
        reportError = nil
    }
}
