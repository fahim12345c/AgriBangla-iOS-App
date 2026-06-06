import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading = false

    private let geminiService: GeminiService

    init(geminiService: GeminiService = .shared) {
        self.geminiService = geminiService
        messages.append(
            ChatMessage(
                role: .assistant,
                content: "👋 সালাম! আমি আপনার কৃষি সহায়ক। ফসল, রোগ, আবহাওয়া বা সার সংক্রান্ত যেকোনো প্রশ্ন করতে পারেন। আমি বাংলায় সহজ করে বুঝিয়ে বলবো। 🌾"
            )
        )
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        messages.append(ChatMessage(role: .user, content: text))
        inputText = ""
        isLoading = true

        Task {
            defer { isLoading = false }
            do {
                let response = try await geminiService.sendMessage(text)
                messages.append(ChatMessage(role: .assistant, content: response))
            } catch let error as ChatError {
                // Shows the real API error so you can debug
                let errorText: String
                switch error {
                case .httpError(let code, let msg):
                    errorText = "⚠️ API Error \(code): \(msg)"
                case .noResponse:
                    errorText = "⚠️ দুঃখিত, কোনো উত্তর পাওয়া যায়নি। আবার চেষ্টা করুন।"
                case .networkError(let e):
                    errorText = "⚠️ নেটওয়ার্ক সমস্যা: \(e.localizedDescription)"
                case .invalidURL:
                    errorText = "⚠️ Invalid URL configuration."
                }
                messages.append(ChatMessage(role: .assistant, content: errorText))
            } catch {
                messages.append(
                    ChatMessage(role: .assistant, content: "⚠️ অজানা সমস্যা: \(error.localizedDescription)")
                )
            }
        }
    }
}
