import Foundation
import Combine

class DrawerViewModel: ObservableObject {
    @Published var userName: String = "Agri AI"
    @Published var userSubtitle: String = "Your Smart Farming Assistant"
    
    // Top menu items
    let topMenuItems: [DrawerMenuItem] = [
        DrawerMenuItem(icon: "person.2.fill", title: "Community", isNew: true),
        DrawerMenuItem(icon: "message.fill", title: "Chat", isNew: false),
        DrawerMenuItem(icon: "cloud.fill", title: "Weather", isNew: false),
        DrawerMenuItem(icon: "camera.viewfinder", title: "Disease Scanner", isNew: false),
        DrawerMenuItem(icon: "newspaper.fill", title: "Agri AI News", isNew: false)
    ]
    
    // Bottom menu items
    let bottomMenuItems: [DrawerMenuItem] = [
        DrawerMenuItem(icon: "character.book.closed.fill", title: "Change Language", isNew: false),
        DrawerMenuItem(icon: "person.fill", title: "Profile", isNew: false),
       // DrawerMenuItem(icon: "envelope.fill", title: "Messages", isNew: false),
        DrawerMenuItem(icon: "graduationcap.fill", title: "Tutorials Agri AI", isNew: false),
        DrawerMenuItem(icon: "questionmark.circle.fill", title: "Help", isNew: false),
        DrawerMenuItem(icon: "info.circle.fill", title: "About", isNew: false)
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
}
