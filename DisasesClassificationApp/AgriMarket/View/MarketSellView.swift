import SwiftUI

struct MarketSellView: View {
    @ObservedObject var vm: MarketViewModel

    @State private var productName = ""
    @State private var price = ""
    @State private var quantityText = ""
    @State private var description = ""
    @State private var selectedCategory: MarketProduct.MarketCategory = .plant

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    private let categories: [(MarketProduct.MarketCategory, String, String)] = [
        (.plant, "Plants & Seeds", "leaf.fill"),
        (.medicine, "Medicines", "pills.fill"),
        (.fertilizer, "Fertilizers", "drop.fill"),
        (.equipment, "Equipment", "wrench.adjustable.fill"),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                categorySection
                formSection
                submitButton
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Add New Product")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)
            Text("Fill in the details below to list your product")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(categories, id: \.0) { cat, label, icon in
                    Button(action: { selectedCategory = cat }) {
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: cat.color))
                                .clipShape(Circle())
                            Text(label)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(selectedCategory == cat ? Color(hex: cat.color).opacity(0.1) : Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedCategory == cat ? Color(hex: cat.color) : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Product Name")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("e.g. Organic Rice", text: $productName)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Price (৳)")
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
                    Text("Quantity")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("0", text: $quantityText)
                        .font(.system(size: 15))
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Description")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("Brief description of your product", text: $description)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var submitButton: some View {
        Button(action: submitProduct) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                Text("List Product")
                    .font(.system(size: 16, weight: .semibold))
            }
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
        !productName.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(price) ?? 0) > 0 &&
        (Int(quantityText) ?? 0) > 0
    }

    private func submitProduct() {
        guard let priceVal = Double(price), priceVal > 0,
              let qty = Int(quantityText), qty > 0 else { return }
        vm.listProductForSale(
            name: productName.trimmingCharacters(in: .whitespaces),
            price: priceVal,
            quantity: qty,
            category: selectedCategory,
            description: description.trimmingCharacters(in: .whitespaces)
        )
        resetForm()
    }

    private func resetForm() {
        productName = ""
        price = ""
        quantityText = ""
        description = ""
        selectedCategory = .plant
    }
}
