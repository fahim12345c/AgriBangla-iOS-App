import SwiftUI

struct HelpView: View {
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)
    private let supportEmail = "fahimalislam1919@gmail.com"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection
                    contactCard
                    faqSection
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(bgColor.ignoresSafeArea())
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(brandGreen)
            Text("Need Help?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("We're here to assist you with any problems or questions.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var contactCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(brandGreen)

            Text("Email Support")
                .font(.system(size: 17, weight: .bold))

            Text(supportEmail)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(brandGreen)

            Text("Send us an email with your issue and we'll get back to you as soon as possible.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            Button(action: sendEmail) {
                HStack(spacing: 8) {
                    Image(systemName: "envelope.fill")
                    Text("Send Email")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(brandGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Frequently Asked Questions")
                .font(.system(size: 17, weight: .bold))

            faqItem(question: "How do I scan a plant disease?",
                    answer: "Open the Disease Scanner tab, tap 'Take Photo' or 'Choose from Library'. The AI will classify the disease and show results.")

            faqItem(question: "Why is the weather not loading?",
                    answer: "Make sure location services are enabled. Pull down to refresh or tap the refresh button.")

            faqItem(question: "How do I change the language?",
                    answer: "Open the navigation drawer from the top-left menu, tap 'Change Language', and select English or বাংলা.")

            faqItem(question: "Can I use the app offline?",
                    answer: "Disease classification works offline (on-device AI). Weather, Chat, and Community require internet connection.")

            faqItem(question: "How do I delete my post?",
                    answer: "Go to the Community tab, tap on your post, then tap the trash icon and confirm deletion.")
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            Text(answer)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }

    private func sendEmail() {
        let subject = "Agri BD App Support".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let body = "Please describe your issue here:".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:\(supportEmail)?subject=\(subject)&body=\(body)") {
            UIApplication.shared.open(url)
        }
    }
}
