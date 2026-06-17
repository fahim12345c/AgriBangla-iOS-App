import SwiftUI
import FirebaseAuth

struct MarketBuyView: View {
    @ObservedObject var vm: MarketViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @State private var showAddToCartAlert = false
    @State private var selectedProduct: MarketProduct?
    @State private var showReviewSheet = false
    @State private var reviewProduct: MarketProduct?
    @State private var reviewRating = 0
    @State private var reviewComment = ""

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
                categoryGrid
                productsSection
                if !vm.cartItems.isEmpty {
                    cartSection
                }
            }
            .padding(20)
            .padding(.bottom, 40)
        }
        .refreshable { vm.loadProducts() }
        .alert("Add to Cart", isPresented: $showAddToCartAlert, presenting: selectedProduct) { product in
            Button("Yes") {
                vm.addToCart(product: product)
                selectedProduct = nil
            }
            Button("No", role: .cancel) {
                selectedProduct = nil
            }
        } message: { product in
            Text("\("Do you want to add") \(product.name)?")
        }
        .sheet(isPresented: $showReviewSheet) {
            reviewSheet
        }
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(categories, id: \.0) { cat, label, icon in
                    categoryCard(category: cat, label: label, icon: icon)
                }
            }
        }
    }

    private func categoryCard(category: MarketProduct.MarketCategory, label: String, icon: String) -> some View {
        Button(action: { vm.filterCategory(category) }) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color(hex: category.color))
                    .clipShape(Circle())

                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(vm.selectedCategory == category ? brandGreen : .clear, lineWidth: 2)
            )
        }
    }

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(vm.selectedCategory.map { categoryDisplayName($0) } ?? "All Products")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                if vm.selectedCategory != nil {
                    Button("Clear") {
                        vm.filterCategory(nil)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                }
            }

            if vm.isLoading {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 80)
                }
            } else if vm.products.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "basket")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No products found")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ForEach(vm.products) { product in
                    productRow(product)
                }
            }
        }
    }

    private func productRow(_ product: MarketProduct) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: product.category.color).opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: product.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: product.category.color))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("৳\(String(format: "%.0f", product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(brandGreen)
                Text(product.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: {
                reviewProduct = product
                reviewRating = 0
                reviewComment = ""
                showReviewSheet = true
            }) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                    .frame(width: 24, height: 24)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(.trailing, 4)

            if product.quantity == 0 {
                Text("Out of Stock")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            } else if vm.canAffordProduct(product.price) {
                Button(action: { vm.addToCart(product: product) }) {
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(brandGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                VStack(spacing: 1) {
                    Image(systemName: "taka.sign.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("\(String(format: "%.0f", product.price))")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange)
                }
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        .onTapGesture {
            if product.quantity > 0 {
                selectedProduct = product
                showAddToCartAlert = true
            }
        }
    }

    private var cartSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(brandGreen)
                Text("Your Cart")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                Text("\(vm.cartCount) \("items")")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            ForEach(vm.cartItems.prefix(3)) { item in
                HStack {
                    Text(item.productName)
                        .font(.system(size: 13))
                    Spacer()
                    Text("\(item.quantity)× ৳\(String(format: "%.0f", item.productPrice))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(brandGreen)
                }
            }

            if vm.cartItems.count > 3 {
                HStack {
                    Spacer()
                    Text("+\(vm.cartItems.count - 3) \("more items")")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                Text("Total:")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("৳\(String(format: "%.2f", vm.cartTotal))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }

            Button(action: {
                coordinator.push(.marketCartView(viewModel: vm))
            }) {
                Text("View Cart Details")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var reviewSheet: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Product")
                        Spacer()
                        Text(reviewProduct.map { $0.name } ?? "")
                            .foregroundColor(.secondary)
                    }
                }

                Section {
                    HStack(spacing: 6) {
                        ForEach(1...5, id: \.self) { i in
                            Button(action: { reviewRating = i }) {
                                Image(systemName: i <= reviewRating ? "star.fill" : "star")
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                } header: {
                    Text("Rating")
                }

                Section {
                    TextField("Share your experience...", text: $reviewComment, axis: .vertical)
                        .lineLimit(3...5)
                } header: {
                    Text("Comment")
                }

                Section {
                    Button(action: submitReview) {
                        Text("Submit Review")
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .disabled(reviewRating == 0 || reviewComment.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showReviewSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func submitReview() {
        guard let product = reviewProduct,
              let uid = Auth.auth().currentUser?.uid else { return }
        let displayName = Auth.auth().currentUser?.displayName ?? "Farmer"
        Task {
            do {
                try await MarketReviewService.shared.addReview(
                    productId: product.id,
                    farmerId: uid,
                    farmerName: displayName,
                    rating: reviewRating,
                    comment: reviewComment.trimmingCharacters(in: .whitespaces)
                )
                vm.toastMessage = "Thank you for your review!"
                showReviewSheet = false
            } catch {
                vm.toastMessage = "Failed to submit review"
                print("Review error: \(error)")
            }
        }
    }

    private func categoryDisplayName(_ category: MarketProduct.MarketCategory) -> String {
        switch category {
        case .plant: return "Plants & Seeds"
        case .medicine: return "Medicines"
        case .fertilizer: return "Fertilizers"
        case .equipment: return "Equipment"
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = int >> 16
        let g = (int >> 8) & 0xFF
        let b = int & 0xFF
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
