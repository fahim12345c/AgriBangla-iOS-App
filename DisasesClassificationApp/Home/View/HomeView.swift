//
//  HomeView.swift
//  DisasesClassificationApp
//

import SwiftUI
import PhotosUI

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var userName: String = "fahimalislam1919"

    var onDiseaseScannerTap: (() -> Void)? = nil
    var onSmartRecommendationsTap: (() -> Void)? = nil
    var onCommunityTap: (() -> Void)? = nil
    var onWeatherTap: (() -> Void)? = nil
    var onChatTap: (() -> Void)? = nil
    var onMarketTap: (() -> Void)? = nil
    var onProfileTap: (() -> Void)? = nil
    var onSearchTap: (() -> Void)? = nil
    var onNotificationTap: (() -> Void)? = nil

    @State private var headerVisible = false
    @State private var weatherVisible = false
    @State private var cardsVisible = false
    @State private var showMenu = false
    let menuWidth: CGFloat = 280
    @State private var showPhotoPicker = false
    @State private var showUploadError = false
    @State private var photoItem: PhotosPickerItem?
    @State private var showNewsSheet = false
    @State private var showProfileSheet = false
    @State private var showTutorialsSheet = false
    @State private var showAboutSheet = false
    @State private var showHelpSheet = false
    @StateObject private var lm = LocalizationManager.shared
    private let newsURL = URL(string: "https://www.bssnews.net/bangla/national/agriculture-news")!

    // Brand green — defined inline so no asset needed
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let pageBg     = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea(.all)

            VStack(spacing: 0) {
                topNavigationBar
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : -20)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        welcomeSection
                            .opacity(headerVisible ? 1 : 0)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)

                        weatherSection
                            .opacity(weatherVisible ? 1 : 0)
                            .offset(y: weatherVisible ? 0 : 30)
                            .padding(.horizontal, 20)

                        featureGridSection
                            .opacity(cardsVisible ? 1 : 0)
                            .offset(y: cardsVisible ? 0 : 30)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100) // tab bar clearance
                    }
                }
            }
            
            if showMenu || animationInProgress {
                            
                // Dim background
                Color.black.opacity(showMenu ? 0.4 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.25), value: showMenu)
                    .onTapGesture {
                        closeMenu()
                    }
                
                // Drawer
                HStack {
                    
                    DrawerView(onNavigate: { destination in
                        closeMenu()
                        switch destination {
                        case .chat: onChatTap?()
                        case .weather: onWeatherTap?()
                        case .market: onMarketTap?()
                        case .diseaseScanner: onDiseaseScannerTap?()
                        case .community: onCommunityTap?()
                        case .profile: showProfileSheet = true
                        case .agriNews: showNewsSheet = true
                        case .tutorials: showTutorialsSheet = true
                        case .about: showAboutSheet = true
                        case .help: showHelpSheet = true
                        case .changeLanguage: break
                        }
                    })
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color.white)
                        .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width * 0.25)
                        .animation(.easeInOut(duration: 0.7), value: showMenu)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }

        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .task(id: photoItem) {
            guard let item = photoItem else { return }
            print("[HomeView] task fired with photoItem: \(item)")
            viewModel.isUploadingProfileImage = true
            do {
                print("[HomeView] Loading transferable data...")
                if let data = try await item.loadTransferable(type: Data.self) {
                    print("[HomeView] Loaded \(data.count) bytes from PhotosPicker")
                    viewModel.uploadProfileImageData(data)
                } else {
                    print("[HomeView] loadTransferable returned nil")
                    viewModel.profileUploadError = "The selected image couldn't be read. Try a different photo."
                    viewModel.isUploadingProfileImage = false
                }
            } catch {
                print("[HomeView] loadTransferable error: \(error.localizedDescription)")
                viewModel.profileUploadError = "Could not load photo: \(error.localizedDescription)"
                viewModel.isUploadingProfileImage = false
                photoItem = nil
            }
        }
        .sheet(isPresented: $showNewsSheet) {
            SafariView(url: newsURL)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showProfileSheet) {
            ProfileView()
        }
        .sheet(isPresented: $showTutorialsSheet) {
            TutorialsView()
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .sheet(isPresented: $showHelpSheet) {
            HelpView()
        }
        .onChange(of: viewModel.profileUploadError) { _ in
            if viewModel.profileUploadError != nil {
                showUploadError = true
            }
        }
        .alert(lm.localized("upload_failed"), isPresented: $showUploadError) {
            Button(lm.localized("general_ok"), role: .cancel) {
                viewModel.profileUploadError = nil
            }
        } message: {
            Text(viewModel.profileUploadError ?? "Could not upload image. Make sure the Cloudinary upload preset is configured.")
        }
        .onAppear {
            viewModel.onAppear(userName: userName)
            animateEntrance()
        }
    }
    
    // Helps smooth dismissal timing
    @State private var animationInProgress = false
    
    func closeMenu() {
        animationInProgress = true
        
        withAnimation(.easeInOut(duration: 0.25)) {
            showMenu = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animationInProgress = false
        }
    }

    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack(spacing: 12) {
            // Hamburger
            Button(action: {
                withAnimation(.easeInOut) {
                    showMenu = true
                }
            }) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: 22, height: 2.5)
                    }
                }
            }

            // Title
            Text("Agri BD")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            // Search
            Button(action: { onSearchTap?() }) {
                HStack(spacing: 5) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 13, weight: .semibold))
                    Text(lm.localized("home_search"))
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5))
            }

            // Bell
            Button(action: { onNotificationTap?() }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Circle().fill(Color.white.opacity(0.2)))
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 1, y: -1)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .padding(.top, 4)
        .background(brandGreen.ignoresSafeArea(edges: .top))
    }

    // MARK: - Welcome Section
    private var welcomeSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                LText("home_welcome")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                Text(viewModel.userName.isEmpty ? "User" : viewModel.userName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Spacer()
            Button(action: {
                print("[HomeView] Profile icon tapped, opening photo picker")
                photoItem = nil
                showPhotoPicker = true
            }) {
                ZStack {
                    Circle()
                        .fill(brandGreen.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Circle()
                        .strokeBorder(brandGreen.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 44, height: 44)
                    if let url = viewModel.profileImageURL, let imageURL = URL(string: url) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(brandGreen)
                            case .empty:
                                ProgressView()
                                    .scaleEffect(0.7)
                            @unknown default:
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(brandGreen)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(brandGreen)
                    }
                    if viewModel.isUploadingProfileImage {
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 44, height: 44)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.7)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Weather Section
    private var weatherSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: lm.localized("home_weather_conditions"), icon: "cloud.sun.fill")
                .onTapGesture { onWeatherTap?() }
            WeatherCardView(
                locationTitle: viewModel.locationTitle,
                weather: viewModel.weather,
                state: viewModel.weatherState,
                onRefresh: { viewModel.refreshWeather() }
            )
        }
    }

    // MARK: - Feature Grid Section
    private var featureGridSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(title: lm.localized("home_smart_support"), icon: "sparkles")
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(Array(viewModel.featureCards.enumerated()), id: \.element.id) { index, card in
                    FeatureCardView(card: card) { handleCardTap(card.destination) }
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.07),
                            value: cardsVisible
                        )
                }
            }
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(brandGreen)
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)
        }
    }

    private func handleCardTap(_ destination: AppDestination) {
        switch destination {
        case .diseaseScanner:       onDiseaseScannerTap?()
        case .smartRecommendations: onChatTap?()
        case .community:            onCommunityTap?()
        case .weather:              onWeatherTap?()
        case .profile:              onProfileTap?()
        }
    }

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.4)) { headerVisible = true }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) { weatherVisible = true }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) { cardsVisible = true }
    }
}

#Preview {
    HomeView(userName: "fahimalislam1919")
}
