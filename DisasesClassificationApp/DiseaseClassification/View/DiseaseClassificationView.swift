import SwiftUI
import PhotosUI

struct DiseaseClassificationView: View {
    @StateObject private var viewModel = DiseaseClassificationViewModel()
    @State private var photoItem: PhotosPickerItem?
    @State private var showShareSheet = false
    @State private var shareData: Data?
    @StateObject private var lm = LocalizationManager.shared

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()

                if !viewModel.isModelLoaded && viewModel.errorMessage == nil {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.selectedImage == nil {
                    errorView(error)
                } else if let image = viewModel.selectedImage {
                    resultView(image)
                } else {
                    emptyState
                }
            }
            .navigationTitle(lm.localized("disease_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.selectedImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: viewModel.reset) { LText("disease_new_scan") }
                    }
                }
            }
            .onAppear {
                viewModel.loadModel()
                viewModel.checkCameraPermission()
            }
            .sheet(isPresented: $viewModel.showCamera) {
                CameraCaptureView(image: $viewModel.selectedImage)
                    .ignoresSafeArea()
                    .onDisappear {
                        if viewModel.selectedImage != nil {
                            viewModel.classifyImage(viewModel.selectedImage!)
                        }
                    }
            }
            .photosPicker(isPresented: $viewModel.showPhotoPicker, selection: $photoItem, matching: .images)
            .onChange(of: photoItem) { _ in
                Task {
                    guard let item = photoItem,
                          let data = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    viewModel.selectImage(image)
                    photoItem = nil
                }
            }
            .confirmationDialog(lm.localized("disease_select_source"), isPresented: $viewModel.showImageSourcePicker) {
                if viewModel.hasCameraPermission == true {
                    Button { viewModel.showCamera = true } label: { LText("disease_take_photo") }
                }
                Button { viewModel.showPhotoPicker = true } label: { LText("disease_choose_library") }
                Button(role: .cancel) { } label: { LText("general_cancel") }
            } message: {
                Text(lm.localized("disease_scan_desc"))
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = shareData {
                    ShareSheet(activityItems: [data])
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            LText("disease_loading_model")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            LText("general_error")
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button { viewModel.loadModel() } label: { LText("general_try_again") }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(brandGreen)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(brandGreen.opacity(0.1))
                .clipShape(Capsule())
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundColor(brandGreen.opacity(0.5))

            LText("disease_scan_leaf")
                .font(.system(size: 22, weight: .bold))

            LText("disease_scan_desc")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 16) {
                Button(action: { viewModel.showImageSourcePicker = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18))
                        LText("disease_take_photo")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: { viewModel.showPhotoPicker = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18))
                        LText("disease_choose_library")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(brandGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(brandGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    private func resultView(_ image: UIImage) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        LText("disease_analyzing")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 30)
                } else if let result = viewModel.result {
                    resultsCard(result)

                    reportSection

                    if let error = viewModel.reportError {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    @ViewBuilder
    private var reportSection: some View {
        if let report = viewModel.reportText {
            VStack(alignment: .leading, spacing: 12) {
                LText("disease_report_title")
                    .font(.system(size: 17, weight: .bold))

                Text(report)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineSpacing(4)

                Button(action: sharePDF) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.doc.fill")
                        LText("disease_download_pdf")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
        } else if viewModel.isGeneratingReport {
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.1)
                LText("disease_generating")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 16)
        } else {
            Button(action: { viewModel.generateReport() }) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                    LText("disease_generate_report")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(brandGreen)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(brandGreen.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
    }

    private func resultsCard(_ result: ClassificationOutput) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            LText("disease_results")
                .font(.system(size: 18, weight: .bold))

            if let top = result.topResults.first {
                HStack {
                    Circle()
                        .fill(statusColor(top.label))
                        .frame(width: 12, height: 12)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatLabel(top.label))
                            .font(.system(size: 17, weight: .semibold))
                        Text("\(Int(top.confidence * 100))% confidence")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(14)
                .background(brandGreen.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            if result.topResults.count > 1 {
                LText("disease_other")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                ForEach(result.topResults.dropFirst()) { item in
                    HStack {
                        Text(formatLabel(item.label))
                            .font(.system(size: 14))
                        Spacer()
                        Text("\(Int(item.confidence * 100))%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }

    private func formatLabel(_ label: String) -> String {
        label
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "/", with: " & ")
    }

    private func statusColor(_ label: String) -> Color {
        let lower = label.lowercased()
        if lower.contains("healthy") { return .green }
        if lower.contains("bacterial") || lower.contains("blight") ||
           lower.contains("mold") || lower.contains("mould") ||
           lower.contains("mildew") || lower.contains("virus") ||
           lower.contains("spot") || lower.contains("mite") {
            return .red
        }
        return .orange
    }

    private func sharePDF() {
        guard let data = viewModel.generatePDF() else { return }
        shareData = data
        showShareSheet = true
    }
}

// MARK: - UIKit Share Sheet Wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
