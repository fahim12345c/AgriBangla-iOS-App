//
//  MainTabView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//
//
//  MainTabView.swift
//  AgriAI Dashboard
//

import SwiftUI

// MARK: - Tab
enum AppTab: Int, CaseIterable {
    case home
    case weather
    case chat
    case diseases

    var title: String {
        switch self {
        case .home:     return "Home"
        case .weather:  return "Weather"
        case .chat:     return "Chat"
        case .diseases: return "Diseases"
        }
    }

    var icon: String {
        switch self {
        case .home:     return "house.fill"
        case .weather:  return "cloud.sun.fill"
        case .chat:     return "message.fill"
        case .diseases: return "camera.fill"
        }
    }
}

// MARK: - MainTabView
struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    // Pass from your coordinator / auth flow
    var userName: String = "Farmer"

    // Coordinator callbacks
    var onDiseaseScannerTap: (() -> Void)? = nil
    var onCommunityTap: (() -> Void)? = nil
    
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                userName: userName,
                onDiseaseScannerTap: { selectedTab = .diseases },
                onCommunityTap: onCommunityTap,
                onWeatherTap: { selectedTab = .weather },
                onProfileTap: nil
            )
            .tag(AppTab.home)

            WeatherFeatureView()
                .tag(AppTab.weather)

            ChatHomeView()
                .tag(AppTab.chat)

            DiseasesScannerView()
                .tag(AppTab.diseases)
        }
        // Avoid .page style; it can break programmatic selection for custom tab bars.
        .tabViewStyle(.automatic)
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
    }

    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                Spacer()
                tabBarItem(tab: tab)
                Spacer()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(
            Color(.systemBackground)
                .overlay(
                    Rectangle()
                        .fill(.black.opacity(0.06))
                        .frame(height: 1),
                    alignment: .top
                )
                .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: -6)
        )
    }

    private func tabBarItem(tab: AppTab) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(brandGreen.opacity(0.18))
                            .frame(width: 48, height: 32)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                        .foregroundColor(selectedTab == tab ? brandGreen : Color.gray.opacity(0.65))
                }
                Text(tab.title)
                    .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? brandGreen : Color.gray.opacity(0.65))
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
    }
}

struct DiseasesScannerView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.18, green: 0.55, blue: 0.34))
            Text("Disease Scanner")
                .font(.title2.bold())
            Text("Integrate your mango leaf classification model here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 30)
    }
}

// MARK: - Preview
#Preview {
    MainTabView(userName: "fahimalislam1919")
}
