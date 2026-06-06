import Foundation
import Combine

class DrawerViewModel: ObservableObject {
    @Published var userName: String = "Agri AI"
    @Published var userSubtitle: String = "Your Smart Farming Assistant"
    
    // Top menu items
    let topMenuItems: [DrawerMenuItem] = [
        DrawerMenuItem(icon: "person.2.fill", title: "Community", isNew: true, destination: .community),
        DrawerMenuItem(icon: "message.fill", title: "Chat", isNew: false, destination: .chat),
        DrawerMenuItem(icon: "cloud.fill", title: "Weather", isNew: false, destination: .weather),
        DrawerMenuItem(icon: "camera.viewfinder", title: "Disease Scanner", isNew: false, destination: .diseaseScanner),
        DrawerMenuItem(icon: "newspaper.fill", title: "Agri AI News", isNew: false, destination: .agriNews)
    ]
    
    // Bottom menu items
    let bottomMenuItems: [DrawerMenuItem] = [
        DrawerMenuItem(icon: "character.book.closed.fill", title: "Change Language", isNew: false, destination: .changeLanguage),
        DrawerMenuItem(icon: "person.fill", title: "Profile", isNew: false, destination: .profile),
        DrawerMenuItem(icon: "graduationcap.fill", title: "Tutorials Agri AI", isNew: false, destination: .tutorials),
        DrawerMenuItem(icon: "questionmark.circle.fill", title: "Help", isNew: false, destination: .help),
        DrawerMenuItem(icon: "info.circle.fill", title: "About", isNew: false, destination: .about)
    ]
    
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
