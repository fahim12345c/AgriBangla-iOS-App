import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct ProfileView: View {
    @StateObject private var lm = LocalizationManager.shared
    @State private var user: UserModel?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var showPhotoPicker = false
    @State private var photoItem: PhotosPickerItem?
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var isUploadingPhoto = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    private var isGoogleUser: Bool {
        Auth.auth().currentUser?.providerData.contains { $0.providerID == "google.com" } ?? false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.5)
                        Text("Loading profile...").font(.system(size: 15)).foregroundColor(.secondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            profilePhotoSection
                            infoSection
                            if isGoogleUser {
                                saveButton
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle(lm.localized("drawer_profile"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: loadUser)
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .task(id: photoItem) {
            guard let item = photoItem else { return }
            isUploadingPhoto = true
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    uploadPhoto(data)
                }
            } catch {
                errorMessage = error.localizedDescription
                isUploadingPhoto = false
            }
            photoItem = nil
        }
        .alert("Success", isPresented: $showSuccess) {
            Button(lm.localized("general_ok"), role: .cancel) { }
        } message: {
            Text("Profile updated successfully.")
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button(lm.localized("general_ok"), role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                if let url = user?.profileImageURL, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            Image(systemName: "person.circle.fill").font(.system(size: 60)).foregroundColor(brandGreen)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            Image(systemName: "person.circle.fill").font(.system(size: 60)).foregroundColor(brandGreen)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(brandGreen)
                }

                if isUploadingPhoto {
                    Circle().fill(Color.black.opacity(0.4)).frame(width: 100, height: 100)
                        .overlay(ProgressView().tint(.white))
                }
            }

            Button(action: { showPhotoPicker = true }) {
                Text("Change Photo")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(brandGreen)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var infoSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                Text(user?.email ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if isGoogleUser {
                editField(label: "First Name", text: $firstName)
                editField(label: "Last Name", text: $lastName)
            } else {
                readOnlyField(label: "First Name", value: user?.firstName ?? "")
                readOnlyField(label: "Last Name", value: user?.lastName ?? "")
            }

            if let dob = user?.dateOfBirth {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Date of Birth").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                    Text(formattedDOB(dob))
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if let createdAt = user?.createdAt {
                Text("Member since \(formattedDate(createdAt))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !isGoogleUser {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("Name and date of birth cannot be changed for email sign-up accounts.")
                        .font(.system(size: 11))
                        .foregroundColor(.orange)
                }
                .padding(10)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func editField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
            TextField(label, text: text)
                .font(.system(size: 16))
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func readOnlyField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var saveButton: some View {
        Button(action: saveProfile) {
            ZStack {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    LText("general_save")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(brandGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isSaving || isUploadingPhoto)
    }

    private func loadUser() {
        Task {
            defer { isLoading = false }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            do {
                user = try await FirestoreManager.shared.fetchUser(userId: uid)
                firstName = user?.firstName ?? ""
                lastName = user?.lastName ?? ""
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        Task {
            do {
                try await Firestore.firestore().collection("users").document(uid).setData([
                    "firstName": firstName,
                    "lastName": lastName
                ], merge: true)
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isSaving = false
        }
    }

    private func uploadPhoto(_ data: Data) {
        guard let uid = Auth.auth().currentUser?.uid,
              let image = UIImage(data: data) else {
            errorMessage = "Could not process image data"
            isUploadingPhoto = false
            return
        }
        Task {
            do {
                let url = try await CloudinaryService.shared.uploadImage(image)
                try await FirestoreManager.shared.updateProfileImageURL(userId: uid, url: url)
                user?.profileImageURL = url
                isUploadingPhoto = false
            } catch {
                errorMessage = error.localizedDescription
                isUploadingPhoto = false
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM yyyy"
        return f.string(from: date)
    }

    private func formattedDOB(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
