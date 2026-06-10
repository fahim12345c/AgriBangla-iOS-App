import SwiftUI

struct MarketOrderConfirmationView: View {
    @StateObject private var lm = LocalizationManager.shared
    @EnvironmentObject private var coordinator: Coordinator

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(brandGreen)

            Text(lm.localized("market_order_placed"))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)

            Text(lm.localized("market_order_placed_msg"))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(action: { coordinator.popToRoot() }) {
                Text(lm.localized("general_ok"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)
            }
        }
        .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}
