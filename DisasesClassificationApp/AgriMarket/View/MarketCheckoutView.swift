import SwiftUI

struct MarketCheckoutView: View {
    @ObservedObject var vm: MarketViewModel
    @EnvironmentObject private var coordinator: Coordinator

    @State private var street = ""
    @State private var city = ""
    @State private var district = ""
    @State private var phone = ""
    @State private var isPlacingOrder = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorAlertMessage = ""

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
        .navigationTitle("Order Summary")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
        .alert("Order Placed!", isPresented: $showSuccessAlert) {
            Button("OK") { coordinator.popToRoot() }
        } message: {
            Text("Your order has been placed successfully. Balance has been updated.")
        }
        .alert("Order Failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorAlertMessage)
        }
    }

    private var orderSummary: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Order Summary")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            ForEach(vm.cartItems) { item in
                HStack {
                    Text(item.productName)
                        .font(.system(size: 14))
                    Spacer()
                    Text("\(item.quantity)× ৳\(String(format: "%.0f", item.productPrice))")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            HStack {
                Text("Total:")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("৳\(String(format: "%.2f", vm.cartTotal))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }

            HStack {
                Text("Balance:")
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
                Text("Delivery Address")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Street / Village")
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
                    Text("City / Town")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                    TextField("", text: $city)
                        .font(.system(size: 15))
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("District")
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
                Text("Phone Number")
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
            HStack(spacing: 8) {
                if isPlacingOrder {
                    ProgressView()
                        .tint(.white)
                }
                Text("Place Order")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(canPlaceOrder && !isPlacingOrder ? brandGreen : Color.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!canPlaceOrder || isPlacingOrder)
    }

    private var canPlaceOrder: Bool {
        vm.canAffordCart &&
        !street.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !district.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func placeOrder() {
        guard !isPlacingOrder else { return }
        isPlacingOrder = true
        let address = DeliveryAddress(
            street: street.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            district: district.trimmingCharacters(in: .whitespaces),
            phone: phone.trimmingCharacters(in: .whitespaces)
        )
        Task {
            do {
                try await vm.placeOrder(address: address)
                isPlacingOrder = false
                showSuccessAlert = true
            } catch {
                isPlacingOrder = false
                errorAlertMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}
