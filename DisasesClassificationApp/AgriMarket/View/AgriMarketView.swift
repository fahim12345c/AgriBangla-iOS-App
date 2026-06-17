import SwiftUI

struct AgriMarketView: View {
    @StateObject private var vm = MarketViewModel()
    @EnvironmentObject private var coordinator: Coordinator
    @State private var showDepositAlert = false
    @State private var depositAmount = ""

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(spacing: 0) {
            if vm.currentUserRole == nil {
                loadingView
            } else {
                balanceBar
                if vm.currentUserRole == .farmer {
                    MarketBuyView(vm: vm)
                } else {
                    MarketSellView(vm: vm)
                }
            }
        }
        .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
        .navigationTitle("Agri Market")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if vm.currentUserRole == .farmer {
                ToolbarItem(placement: .navigationBarTrailing) {
                    cartButton
                }
            }
        }
        .task {
            await vm.loadCurrentUser()
            if vm.currentUserRole == .farmer {
                vm.loadProducts()
            }
        }
        .alert("Listing Submitted!", isPresented: $vm.showSellSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your crop has been listed for sale.")
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

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(brandGreen)
            Text("Loading...")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var balanceBar: some View {
        HStack {
            Image(systemName: "taka.sign.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(brandGreen)
            Text("Balance:")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text("৳\(String(format: "%.2f", vm.userBalance))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)

            Spacer()

            if vm.currentUserRole == .farmer {
                Button(action: { showDepositAlert = true }) {
                    Text("+\("Deposit")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(brandGreen)
                        .clipShape(Capsule())
                }
                .alert("Deposit", isPresented: $showDepositAlert) {
                    TextField("Enter Amount", text: $depositAmount)
                        .keyboardType(.decimalPad)
                    Button("Deposit Now") {
                        if let amount = Double(depositAmount), amount > 0 {
                            vm.deposit(amount: amount)
                        }
                        depositAmount = ""
                    }
                    Button("Cancel", role: .cancel) {
                        depositAmount = ""
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private var cartButton: some View {
        Button(action: {
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
