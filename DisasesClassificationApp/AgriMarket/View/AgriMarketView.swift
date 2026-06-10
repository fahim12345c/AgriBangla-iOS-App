import SwiftUI

struct AgriMarketView: View {
    @StateObject private var vm = MarketViewModel()
    @StateObject private var lm = LocalizationManager.shared
    @EnvironmentObject private var coordinator: Coordinator
    @State private var selectedTab = 0
    @State private var showDepositAlert = false
    @State private var depositAmount = ""

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(spacing: 0) {
            balanceBar

            Picker("", selection: $selectedTab) {
                Text(lm.localized("market_buy")).tag(0)
                Text(lm.localized("market_sell")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            if selectedTab == 0 {
                MarketBuyView(vm: vm)
            } else {
                MarketSellView(vm: vm)
            }
        }
        .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
        .navigationTitle(lm.localized("drawer_market"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                cartButton
            }
        }
        .onAppear {
            vm.loadProducts()
            vm.loadCart()
            vm.loadBalance()
        }
        .alert(lm.localized("market_listing_submitted"), isPresented: $vm.showSellSuccess) {
            Button(lm.localized("general_ok"), role: .cancel) { }
        } message: {
            Text(lm.localized("market_listing_submitted_msg"))
        }
        .overlay(alignment: .bottom) {
            if let msg = vm.toastMessage {
                Text(msg)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(brandGreen.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { vm.toastMessage = nil }
                        }
                    }
            }
        }
        .animation(.spring(), value: vm.toastMessage != nil)
    }

    private var balanceBar: some View {
        HStack {
            Image(systemName: "taka.sign.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(brandGreen)
            Text(lm.localized("market_balance"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text("৳\(String(format: "%.2f", vm.userBalance))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)

            Spacer()

            cartButton
                .padding(.trailing, 8)

            Button(action: { showDepositAlert = true }) {
                Text("+\(lm.localized("market_deposit"))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(brandGreen)
                    .clipShape(Capsule())
            }
            .alert(lm.localized("market_deposit"), isPresented: $showDepositAlert) {
                TextField(lm.localized("market_deposit_amount"), text: $depositAmount)
                    .keyboardType(.decimalPad)
                Button(lm.localized("market_deposit_confirm")) {
                    if let amount = Double(depositAmount), amount > 0 {
                        vm.deposit(amount: amount)
                    }
                    depositAmount = ""
                }
                Button(lm.localized("general_cancel"), role: .cancel) {
                    depositAmount = ""
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var cartButton: some View {
        Button(action: {
            vm.loadCart()
            coordinator.push(.marketCartView(viewModel: vm))
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 18))
                    .foregroundColor(brandGreen)
                if vm.cartCount > 0 {
                    Text("\(vm.cartCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }
}
