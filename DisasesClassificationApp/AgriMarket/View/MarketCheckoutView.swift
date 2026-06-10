import SwiftUI

struct MarketCheckoutView: View {
    @ObservedObject var vm: MarketViewModel
    @StateObject private var lm = LocalizationManager.shared
    @EnvironmentObject private var coordinator: Coordinator

    @State private var street = ""
    @State private var city = ""
    @State private var district = ""
    @State private var phone = ""

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                orderSummary
                addressForm
                placeOrderButton
            }
            .padding(20)
        }
        .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
        .navigationTitle(lm.localized("market_order_summary"))
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
    }

    private var orderSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text(lm.localized("market_order_summary"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            ForEach(vm.cartItems) { item in
                HStack {
                    Text(lm.currentLanguage == .bangla ? item.productNameBN : item.productName)
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(item.quantity)× ৳\(String(format: "%.0f", item.productPrice))")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                Text(lm.localized("market_total"))
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("৳\(String(format: "%.2f", vm.cartTotal))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }

            HStack {
                Text(lm.localized("market_balance"))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
                Text("৳\(String(format: "%.2f", vm.userBalance))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(vm.canAffordCart ? brandGreen : .red)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var addressForm: some View {
        VStack(spacing: 14) {
            HStack {
                Text(lm.localized("market_delivery_address"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(lm.localized("market_address_street"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $street)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(lm.localized("market_address_city"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("", text: $city)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(lm.localized("market_address_district"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("", text: $district)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(lm.localized("market_address_phone"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                TextField("", text: $phone)
                    .font(.system(size: 15))
                    .keyboardType(.phonePad)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var placeOrderButton: some View {
        Button(action: placeOrder) {
            Text(lm.localized("market_place_order"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(canPlaceOrder ? brandGreen : Color.gray.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canPlaceOrder)
    }

    private var canPlaceOrder: Bool {
        vm.canAffordCart &&
        !street.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !district.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func placeOrder() {
        let address = DeliveryAddress(
            street: street.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            district: district.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces)
        )
        vm.placeOrder(address: address)
        coordinator.push(.marketOrderConfirmation)
    }
}
