import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?

    var onCreatePost: ((String, UIImage?) -> Void)?

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextEditor(text: $viewModel.text)
                    .font(.system(size: 16))
                    .padding(12)
                    .frame(height: 150)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandGreen.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(alignment: .topLeading) {
                        if viewModel.text.isEmpty {
                            Text("What's on your mind?")
                                .font(.system(size: 16))
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }

                if let image = viewModel.selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button(action: { viewModel.clearImage() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                                .padding(8)
                        }
                    }
                }

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Add Photo", systemImage: "photo")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(brandGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(brandGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .onChange(of: photoItem) { _ in
                    Task {
                        if let data = try? await photoItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.selectedImage = uiImage
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let text = viewModel.text
                        let image = viewModel.selectedImage
                        dismiss()
                        onCreatePost?(text, image)
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

#Preview {
    CreatePostView()
}
