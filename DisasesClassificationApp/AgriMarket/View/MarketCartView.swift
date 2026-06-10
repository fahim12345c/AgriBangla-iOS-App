import SwiftUI

struct MarketCartView: View {
    @ObservedObject var vm: MarketViewModel
    @StateObject private var lm = LocalizationManager.shared
    @EnvironmentObject private var coordinator: Coordinator

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea()

            if vm.cartItems.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(vm.cartItems) { item in
                                cartItemRow(item)
                            }
                        }
                        .padding(20)
                    }

                    VStack(spacing: 12) {
                        HStack {
                            Text(lm.localized("market_balance"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("৳\(String(format: "%.2f", vm.userBalance))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(brandGreen)
                        }

                        HStack {
                            Text(lm.localized("market_total"))
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Text("৳\(String(format: "%.2f", vm.cartTotal))")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(brandGreen)
                        }

                        Button(action: proceedToCheckout) {
                            HStack(spacing: 8) {
                                Image(systemName: "shippingbox.fill")
                                Text(lm.localized("market_checkout"))
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(vm.canAffordCart ? brandGreen : Color.gray.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!vm.canAffordCart)

                        if !vm.canAffordCart {
                            Text(lm.localized("market_insufficient_balance"))
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }

                        Button(action: { vm.clearCart() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text(lm.localized("market_clear_cart"))
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                }
            }
        }
        .navigationTitle(lm.localized("market_cart"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.4))
            Text(lm.localized("market_cart_empty"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Button(lm.localized("general_ok")) { coordinator.pop() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(brandGreen)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(brandGreen.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func cartItemRow(_ item: CartItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: item.category == "plant" ? "34C759" : item.category == "medicine" ? "FF9500" : item.category == "fertilizer" ? "5AC8FA" : "FF2D55").opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: item.productIcon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: item.category == "plant" ? "34C759" : item.category == "medicine" ? "FF9500" : item.category == "fertilizer" ? "5AC8FA" : "FF2D55"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(lm.currentLanguage == .bangla ? item.productNameBN : item.productName)
                    .font(.system(size: 14, weight: .semibold))
                Text("৳\(String(format: "%.0f", item.productPrice))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(brandGreen)
            }

            Spacer()

            HStack(spacing: 10) {
                Button(action: { vm.updateQuantity(cartItemID: item.id, quantity: item.quantity - 1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(brandGreen.opacity(0.7))
                }

                Text("\(item.quantity)")
                    .font(.system(size: 15, weight: .bold))
                    .frame(minWidth: 24)

                Button(action: { vm.updateQuantity(cartItemID: item.id, quantity: item.quantity + 1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(brandGreen)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private func proceedToCheckout() {
        coordinator.push(.marketCheckoutView(viewModel: vm))
    }
}
