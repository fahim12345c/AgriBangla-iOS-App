import SwiftUI
import FirebaseAuth

enum AppTab: Int, CaseIterable {
    case home
    case market
    case weather
    case chat
    case community
    case diseases

    var title: String {
        switch self {
        case .home:      return "Home"
        case .market:    return "Market"
        case .weather:   return "Weather"
        case .chat:      return "Chat"
        case .community: return "Community"
        case .diseases:  return "Diseases"
        }
    }

    var icon: String {
        switch self {
        case .home:      return "house.fill"
        case .market:    return "cart.fill"
        case .weather:   return "cloud.sun.fill"
        case .chat:      return "message.fill"
        case .community: return "person.3.fill"
        case .diseases:  return "camera.fill"
        }
    }
}

enum SellerTab: Int, CaseIterable {
    case dashboard
    case market

    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .market:    return "Market"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .market:    return "cart.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var selectedSellerTab: SellerTab = .dashboard
    @State private var userRole: UserRole?
    @State private var userName: String = "Farmer"

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        Group {
            if let role = userRole {
                if role == .seller {
                    sellerBody
                } else {
                    farmerBody
                }
            } else {
                loadingView
            }
        }
        .task {
            await loadUserRole()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundColor(brandGreen)
            ProgressView()
                .tint(brandGreen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
    }

    // MARK: - Farmer Tabs

    private var farmerBody: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                userName: userName,
                onDiseaseScannerTap: { selectedTab = .diseases },
                onCommunityTap: { selectedTab = .community },
                onWeatherTap: { selectedTab = .weather },
                onChatTap: { selectedTab = .chat },
                onMarketTap: { selectedTab = .market },
                onProfileTap: nil
            )
            .tag(AppTab.home)

            AgriMarketView()
                .tag(AppTab.market)

            WeatherFeatureView(onBack: { selectedTab = .home })
                .tag(AppTab.weather)

            ChatHomeView()
                .tag(AppTab.chat)

            CommunityView()
                .tag(AppTab.community)

            DiseaseClassificationView()
                .tag(AppTab.diseases)
        }
        .tabViewStyle(.automatic)
        .safeAreaInset(edge: .bottom) {
            farmerTabBar
        }
    }

    // MARK: - Seller Tabs

    private var sellerBody: some View {
        TabView(selection: $selectedSellerTab) {
            SellerHomeView()
                .tag(SellerTab.dashboard)

            AgriMarketView()
                .tag(SellerTab.market)
        }
        .tabViewStyle(.automatic)
        .safeAreaInset(edge: .bottom) {
            sellerTabBar
        }
    }

    // MARK: - Farmer Tab Bar

    private var farmerTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Spacer()
                tabBarItem(icon: tab.icon, title: tab.title, isSelected: selectedTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = tab }
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(tabBarBackground)
    }

    // MARK: - Seller Tab Bar

    private var sellerTabBar: some View {
        HStack(spacing: 0) {
            ForEach(SellerTab.allCases, id: \.rawValue) { tab in
                Spacer()
                tabBarItem(icon: tab.icon, title: tab.title, isSelected: selectedSellerTab == tab) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedSellerTab = tab }
                }
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(tabBarBackground)
    }

    // MARK: - Shared

    private var tabBarBackground: some View {
        Color(.systemBackground)
            .overlay(
                Rectangle()
                    .fill(.black.opacity(0.06))
                    .frame(height: 1),
                alignment: .top
            )
            .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: -6)
    }

    private func tabBarItem(icon: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(brandGreen.opacity(0.18))
                            .frame(width: 48, height: 32)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? brandGreen : Color.gray.opacity(0.65))
                }
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? brandGreen : Color.gray.opacity(0.65))
            }
        }
        .buttonStyle(.plain)
    }

    private func loadUserRole() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let user = try? await FirestoreManager.shared.fetchUser(userId: uid) {
            userRole = user.role ?? .farmer
            userName = [user.firstName, user.lastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        }
    }
}

#Preview {
    MainTabView()
}
