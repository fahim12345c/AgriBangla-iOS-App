import SwiftUI

struct AboutView: View {
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(brandGreen.opacity(0.12))
                                .frame(width: 80, height: 80)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 36))
                                .foregroundColor(brandGreen)
                        }

                        Text("Agri BD")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(brandGreen)

                        Text("Smart Farming Assistant")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    infoCard(
                        title: "Version",
                        detail: "1.0.0"
                    )
                    infoCard(
                        title: "Purpose",
                        detail: "Agri BD helps Bangladeshi farmers diagnose plant diseases using on-device AI, get Bangla treatment advice with medicine recommendations, check spray-weather windows, chat with an AI assistant in Bangla, and connect with a farming community."
                    )
                    infoCard(
                        title: "Key Features",
                        detail: "• 🔬 Disease Scanner — Classifies 29 diseases across Mango, Potato, Rice & Tomato\n• 📋 AI Bangla Report — Generates treatment advice with medicine names\n• 🌦️ Weather & Spraying — Delta-T spray window calculator\n• 💬 AI Chat — Ask farming questions in Bangla\n• 👥 Community — Share & learn from other farmers\n• 📄 PDF Export — Download disease reports"
                    )
                    infoCard(
                        title: "Technology",
                        detail: "Built with SwiftUI + Firebase + TensorFlow Lite + Gemini AI. On-device disease classification works without internet."
                    )

                    Text("© 2026 Agri BD. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func infoCard(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(brandGreen)
            Text(detail)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}
