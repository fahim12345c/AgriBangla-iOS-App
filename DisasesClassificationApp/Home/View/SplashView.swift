import SwiftUI

struct SplashView: View {
    @State private var progress: CGFloat = 0
    @State private var showApp = false
    @State private var opacity: Double = 1

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let darkGreen = Color(red: 0.12, green: 0.40, blue: 0.24)

    var body: some View {
        ZStack {
            if showApp {
                CoordinatorView()
                    .transition(.opacity)
            } else {
                ZStack {
                    LinearGradient(
                        colors: [brandGreen, darkGreen],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 0) {
                        Spacer()

                        leafIcon
                            .padding(.bottom, 16)

                        Text("Agri BD")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Smart Farming Assistant")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                            .padding(.top, 4)

                        Spacer()

                        loadingSection
                            .padding(.bottom, 60)
                    }
                }
                .opacity(opacity)
            }
        }
        .onAppear(perform: startLoading)
    }

    private var leafIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 100, height: 100)

            Image(systemName: "leaf.fill")
                .font(.system(size: 44))
                .foregroundColor(.white)
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 240, height: 12)

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .frame(width: 240 * progress, height: 12)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }

            Text(loadingText)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    private var loadingText: String {
        if progress < 0.3 { return "Initializing..." }
        if progress < 0.6 { return "Loading resources..." }
        if progress < 0.9 { return "Almost ready..." }
        return "Welcome!"
    }

    private func startLoading() {
        let totalSteps = 20
        let interval = 0.08

        for step in 0...totalSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * interval) {
                progress = CGFloat(step) / CGFloat(totalSteps)
                if step == totalSteps {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showApp = true
                        }
                    }
                }
            }
        }
    }
}
