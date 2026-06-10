import SwiftUI

struct MarketBuyView: View {
    @ObservedObject var vm: MarketViewModel
    @StateObject private var lm = LocalizationManager.shared
    @EnvironmentObject private var coordinator: Coordinator
    @State private var showAddToCartAlert = false
    @State private var selectedProduct: MarketProduct?

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    private let categories: [(MarketProduct.MarketCategory, String, String)] = [
        (.plant, "market_plants", "leaf.fill"),
        (.medicine, "market_medicines", "pills.fill"),
        (.fertilizer, "market_fertilizers", "drop.fill"),
        (.equipment, "market_equipment", "wrench.adjustable.fill"),
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
        .alert(lm.localized("market_add_to_cart_title"), isPresented: $showAddToCartAlert, presenting: selectedProduct) { product in
            Button(lm.localized("general_yes")) {
                vm.addToCart(product: product)
                selectedProduct = nil
            }
            Button(lm.localized("general_no"), role: .cancel) {
                selectedProduct = nil
            }
        } message: { product in
            Text("\(lm.localized("market_add_to_cart_msg")) \(lm.currentLanguage == .bangla ? product.nameBN : product.name)?")
        }
    }

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(lm.localized("market_categories"))
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

                Text(lm.localized(label))
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
                Text(vm.selectedCategory.map { lm.localized(categoryLabel($0)) } ?? lm.localized("market_all_products"))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                if vm.selectedCategory != nil {
                    Button(lm.localized("market_clear_filter")) {
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
                    Text(lm.localized("market_no_products"))
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
                Text(lm.currentLanguage == .bangla ? product.nameBN : product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text("৳\(String(format: "%.0f", product.price))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(brandGreen)
                Text(lm.currentLanguage == .bangla ? product.descriptionBN : product.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if product.quantity == 0 {
                Text(lm.localized("market_out_of_stock"))
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
                Text(lm.localized("market_your_cart"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                Text("\(vm.cartCount) \(lm.localized("market_items"))")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            ForEach(vm.cartItems.prefix(3)) { item in
                HStack {
                    Text(lm.currentLanguage == .bangla ? item.productNameBN : item.productName)
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
                    Text("+\(vm.cartItems.count - 3) \(lm.localized("market_more_items"))")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                Text(lm.localized("market_total"))
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("৳\(String(format: "%.2f", vm.cartTotal))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }

            Button(action: {
                vm.loadCart()
                coordinator.push(.marketCartView(viewModel: vm))
            }) {
                Text(lm.localized("market_view_cart"))
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

    private func categoryLabel(_ category: MarketProduct.MarketCategory) -> String {
        switch category {
        case .plant: return "market_plants"
        case .medicine: return "market_medicines"
        case .fertilizer: return "market_fertilizers"
        case .equipment: return "market_equipment"
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
