import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading = false
    @Published var activeProvider: AIProvider = .gemini  // shown in UI if desired

    private let geminiService: GeminiService
    private let deepSeekService: DeepSeekService

    init(
        geminiService: GeminiService = .shared,
        deepSeekService: DeepSeekService = .shared
    ) {
        self.geminiService = geminiService
        self.deepSeekService = deepSeekService
        messages.append(
            ChatMessage(
                role: .assistant,
                content: "👋 Hello! I am your farming assistant. Ask me anything about crops, diseases, weather, or fertilizers. 🌾",
                provider: .none
            )
        )
    }

    // MARK: - Send

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isLoading else { return }

        messages.append(ChatMessage(role: .user, content: text, provider: .none))
        inputText = ""
        isLoading = true

        Task {
            defer { isLoading = false }
            await resolveResponse(for: text)
        }
    }

    // MARK: - Resolution chain: Gemini → DeepSeek

    private func resolveResponse(for text: String) async {
        // 1️⃣ Try Gemini first
        do {
            let response = try await geminiService.sendMessage(text)
            activeProvider = .gemini
            messages.append(ChatMessage(role: .assistant, content: response, provider: .gemini))
            return
        } catch ChatError.quotaExhausted {
            // Gemini quota exhausted across all models → fall through to DeepSeek
            print("⚠️ Gemini quota exhausted — falling back to DeepSeek")
        } catch {
            // Any other Gemini error (network, 400, etc.) — show immediately, don't try DeepSeek
            appendError(error, provider: .gemini)
            return
        }

        // 2️⃣ Gemini quota exhausted → try DeepSeek
        do {
            let response = try await deepSeekService.sendMessage(text)
            activeProvider = .deepSeek
            // Subtle notice so the user knows a fallback was used (optional — remove if unwanted)
            messages.append(ChatMessage(role: .assistant, content: response, provider: .deepSeek))
        } catch {
            appendError(error, provider: .deepSeek)
        }
    }

    // MARK: - Error helper

    private func appendError(_ error: Error, provider: AIProvider) {
        let providerName = provider == .deepSeek ? "DeepSeek" : "Gemini"
        let text: String

        if let chatError = error as? ChatError {
            switch chatError {
            case .httpError(let code, let msg):
                text = "⚠️ \(providerName) Error \(code): \(msg)"
            case .noResponse:
                text = "⚠️ Sorry, no response received. Please try again."
            case .networkError(let e):
                text = "⚠️ Network error: \(e.localizedDescription)"
            case .invalidURL:
                text = "⚠️ Invalid URL configuration."
            case .quotaExhausted:
                text = "⚠️ All AI server quotas exhausted. Please try again later. 🙏"
            }
        } else {
            text = "⚠️ Unknown error: \(error.localizedDescription)"
        }

        messages.append(ChatMessage(role: .assistant, content: text, provider: .none))
    }
}
