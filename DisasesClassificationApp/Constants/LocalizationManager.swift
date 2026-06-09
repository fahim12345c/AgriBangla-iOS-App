import Foundation
import Combine
import SwiftUI

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: Language

    enum Language: String, CaseIterable {
        case english = "en"
        case bangla = "bn"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .bangla: return "বাংলা"
            }
        }

        var locale: Locale {
            Locale(identifier: rawValue)
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_language") ?? "bn"
        self.currentLanguage = Language(rawValue: saved) ?? .bangla
    }

    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
    }

    func localized(_ key: String) -> String {
        LocalizedStrings.string(for: key, language: currentLanguage)
    }
}
