import Foundation
import Combine

class DrawerViewModel: ObservableObject {
    @Published var userName: String = "Agri BD"

    var userSubtitle: String {
        LocalizationManager.shared.localized("drawer_subtitle")
    }

    var topMenuItems: [DrawerMenuItem] {
        let lm = LocalizationManager.shared
        return [
            DrawerMenuItem(icon: "cart.fill", title: lm.localized("drawer_market"), isNew: true, destination: .market),
            DrawerMenuItem(icon: "person.2.fill", title: lm.localized("drawer_community"), isNew: false, destination: .community),
            DrawerMenuItem(icon: "message.fill", title: lm.localized("drawer_chat"), isNew: false, destination: .chat),
            DrawerMenuItem(icon: "cloud.fill", title: lm.localized("drawer_weather"), isNew: false, destination: .weather),
            DrawerMenuItem(icon: "camera.viewfinder", title: lm.localized("drawer_disease_scanner"), isNew: false, destination: .diseaseScanner),
            DrawerMenuItem(icon: "newspaper.fill", title: lm.localized("drawer_news"), isNew: false, destination: .agriNews)
        ]
    }

    var bottomMenuItems: [DrawerMenuItem] {
        let lm = LocalizationManager.shared
        return [
            DrawerMenuItem(icon: "character.book.closed.fill", title: lm.localized("drawer_change_language"), isNew: false, destination: .changeLanguage),
            DrawerMenuItem(icon: "person.fill", title: lm.localized("drawer_profile"), isNew: false, destination: .profile),
            DrawerMenuItem(icon: "graduationcap.fill", title: lm.localized("drawer_tutorials"), isNew: false, destination: .tutorials),
            DrawerMenuItem(icon: "questionmark.circle.fill", title: lm.localized("drawer_help"), isNew: false, destination: .help),
            DrawerMenuItem(icon: "info.circle.fill", title: lm.localized("drawer_about"), isNew: false, destination: .about)
        ]
    }

    func logout() {
        do {
            try AuthManager.shared.logout()
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
}

struct DrawerMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let isNew: Bool
    let destination: DrawerDestination
}

enum DrawerDestination {
    case market
    case community
    case chat
    case weather
    case diseaseScanner
    case agriNews
    case changeLanguage
    case profile
    case tutorials
    case help
    case about
}
