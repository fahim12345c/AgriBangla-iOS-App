import SwiftUI
import PhotosUI

struct MarketSellView: View {
    @ObservedObject var vm: MarketViewModel
    @StateObject private var lm = LocalizationManager.shared

    @State private var cropName = ""
    @State private var cropNameBN = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var quantityBN = ""
    @State private var description = ""
    @State private var descriptionBN = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                photoSection
                formSection
                submitButton
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private var photoSection: some View {
        PhotosPicker(selection: $selectedImage, matching: .images) {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 140)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(brandGreen.opacity(0.6))
                            Text(lm.localized("market_add_photo"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
            }
        }
        .onChange(of: selectedImage) { newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                imageData = data
            }
        }
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(lm.localized("market_crop_name"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $cropName)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(lm.localized("market_crop_name")) (Bangla)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $cropNameBN)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lm.localized("market_price"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("0", text: $price)
                        .font(.system(size: 15))
                        .keyboardType(.decimalPad)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(lm.localized("market_quantity"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("", text: $quantity)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(lm.localized("market_quantity")) (BN)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("", text: $quantityBN)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(lm.localized("market_description"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $description)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(lm.localized("market_description")) (Bangla)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $descriptionBN)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var submitButton: some View {
        Button(action: submitListing) {
            Text(lm.localized("market_list_crop"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? brandGreen : Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!isFormValid)
        .padding(.top, 4)
    }

    private var isFormValid: Bool {
        !cropName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cropNameBN.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(price) ?? 0) > 0 &&
        !quantity.trimmingCharacters(in: .whitespaces).isEmpty &&
        !quantityBN.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitListing() {
        guard let priceVal = Double(price), priceVal > 0 else { return }
        vm.listCropForSale(
            cropName: cropName.trimmingCharacters(in: .whitespaces),
            cropNameBN: cropNameBN.trimmingCharacters(in: .whitespaces),
            price: priceVal,
            quantity: quantity.trimmingCharacters(in: .whitespaces),
            quantityBN: quantityBN.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            descriptionBN: descriptionBN.trimmingCharacters(in: .whitespaces),
            imageData: imageData
        )
        resetForm()
    }

    private func resetForm() {
        cropName = ""
        cropNameBN = ""
        price = ""
        quantity = ""
        quantityBN = ""
        description = ""
        descriptionBN = ""
        imageData = nil
        selectedImage = nil
    }
}
