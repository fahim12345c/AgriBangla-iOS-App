import SwiftUI

struct TutorialsView: View {
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    featureSteps
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Tutorials")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundColor(brandGreen)
            Text("Welcome to Agri BD!")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("Your complete smart farming assistant.\nLearn how to use each feature below.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var featureSteps: some View {
        VStack(spacing: 14) {
            stepCard(
                icon: "house.fill",
                title: "Home Dashboard",
                desc: "View weather updates, access all features from the grid, tap your profile photo to upload a picture, and open the navigation drawer from the top-left menu."
            )
            stepCard(
                icon: "cloud.sun.fill",
                title: "Weather & Spraying",
                desc: "Check real-time weather data. Use the Spray tab to see if conditions are optimal for spraying pesticides (Delta-T calculation). Tap the BAMIS link for detailed Bangladesh weather data."
            )
            stepCard(
                icon: "message.fill",
                title: "AI Chat (বাংলা)",
                desc: "Ask any farming question in Bangla. The AI assistant responds in simple Bangla with emojis and practical advice. Powered by Gemini with DeepSeek fallback."
            )
            stepCard(
                icon: "person.3.fill",
                title: "Community",
                desc: "Share posts with photos, comment on other farmers' posts, and react with Like, Love, or Helpful. Edit or delete your own posts anytime."
            )
            stepCard(
                icon: "camera.fill",
                title: "Disease Scanner",
                desc: "Take a photo of a diseased leaf or choose from your library. The app classifies 29 diseases across Mango, Potato, Rice, and Tomato. Tap 'Generate Advice Report' for a Bangla treatment report with medicine names. Download as PDF."
            )
            stepCard(
                icon: "person.fill",
                title: "Profile",
                desc: "Tap your profile picture on the home screen or go to Profile from the drawer. Edit your name and update your photo."
            )
            stepCard(
                icon: "character.book.closed.fill",
                title: "Language",
                desc: "Go to Drawer → Change Language to switch between English and বাংলা. The entire app UI will update instantly."
            )
        }
    }

    private func stepCard(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(brandGreen.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(brandGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}
