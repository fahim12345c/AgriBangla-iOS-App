//
//  LoginView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 5/5/26.
//

import SwiftUI
 
// MARK: - LoginView
struct LoginView: View {
    @StateObject var viewModel:LoginViewModel
    @EnvironmentObject private var coordinator:Coordinator
    @Environment(\.dismiss) private var dismiss
 
    // Entrance animation states
    @State private var headerScale: CGFloat = 0.85
    @State private var formOpacity: Double = 0
    @State private var formOffset: CGFloat = 30
 
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: Background
                MangoTheme.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerCard
                            .scaleEffect(headerScale)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        formSection
                            .opacity(formOpacity)
                            .offset(y: formOffset)
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        
                        footerLink
                            .opacity(formOpacity)
                            .padding(.top, 24)
                            .padding(.bottom, 40)
                    }
                }
                
                // MARK: Overlays
                if viewModel.authState == .loading { loadingOverlay }
                if viewModel.authState == .success { successOverlay }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { backButton }
            }
            .onChange(of: viewModel.authState) { state in
                if case .success = state {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.coordinator.replaceStack(with: .homeView)
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                    headerScale = 1.0
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
                    formOpacity = 1
                    formOffset = 0
                }
            }
            .alert(item: alertItem) { item in
                Alert(
                    title: Text("Login Failed"),
                    message: Text(item.message),
                    dismissButton: .default(Text("OK")) { viewModel.resetState() }
                )
            }
        }
    }
 
    // MARK: - Header Card
    private var headerCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(MangoTheme.headerGradient)
                .shadow(color: MangoTheme.primaryOrange.opacity(0.35), radius: 16, x: 0, y: 8)
 
            VStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 68, height: 68)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                .padding(.top, 28)
 
                Text("Welcome Back")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
 
                Text("Sign in to your Mango account")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.bottom, 28)
            }
        }
        .frame(maxWidth: .infinity)
    }
 
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
 
            // Email Field
            MangoTextField(
                placeholder: "Email Address",
                systemImage: "envelope",
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                onEditingChanged: { focused in
                    if !focused { viewModel.validateEmail() }
                }
            )
 
            // Password Field
            MangoTextField(
                placeholder: "Password",
                systemImage: "lock",
                text: $viewModel.password,
                errorMessage: viewModel.passwordError,
                isSecure: true,
                isRevealed: viewModel.isPasswordVisible,
                toggleReveal: { viewModel.isPasswordVisible.toggle() },
                onEditingChanged: { focused in
                    if !focused { viewModel.validatePassword() }
                }
            )
 
            // Remember Me + Forgot Password
            HStack {
                rememberMeToggle
                Spacer()
                forgotPasswordButton
            }
            .padding(.horizontal, 2)
 
            // Login Button
            loginButton
                .padding(.top, 4)
 
            // Divider
            dividerRow
 
            // Social Login
            socialLoginRow
        }
    }
 
    // MARK: - Remember Me Toggle
    private var rememberMeToggle: some View {
        Button(action: { viewModel.rememberMe.toggle() }) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            viewModel.rememberMe ? MangoTheme.primaryOrange : Color.gray.opacity(0.4),
                            lineWidth: 1.5
                        )
                        .frame(width: 18, height: 18)
                    if viewModel.rememberMe {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(MangoTheme.headerGradient)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.25), value: viewModel.rememberMe)
 
                Text("Remember me")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
 
    // MARK: - Forgot Password
    private var forgotPasswordButton: some View {
        Button("Forgot Password?") {
            viewModel.showForgotPasswordAlert = true
        }
        .alert("Reset Password", isPresented: $viewModel.showForgotPasswordAlert) {
            TextField("Enter your email", text: $viewModel.forgotPasswordEmail)
            Button("Send Reset Link") { viewModel.sendPasswordReset() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundColor(MangoTheme.primaryOrange)
    }
 
    // MARK: - Login Button
    private var loginButton: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            viewModel.login()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        viewModel.isFormValid
                            ? MangoTheme.headerGradient
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                startPoint: .leading, endPoint: .trailing
                            )
                    )
                    .shadow(
                        color: viewModel.isFormValid ? MangoTheme.primaryOrange.opacity(0.4) : .clear,
                        radius: 8, x: 0, y: 4
                    )
 
                Text("Sign In")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(viewModel.isFormValid ? .white : .gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .disabled(!viewModel.isFormValid || viewModel.authState == .loading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
        .scaleEffect(viewModel.isFormValid ? 1.0 : 0.98)
    }
 
    // MARK: - Divider Row
    private var dividerRow: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            Text("or continue with")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.7))
                .fixedSize()
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }
        .padding(.vertical, 4)
    }
 
    // MARK: - Social Login Row
    private var socialLoginRow: some View {
        
        HStack(spacing: 16) {
            googleSignInButton
//            socialButton(icon: "g.circle.fill", label: "Google",  color: Color(red: 0.85, green: 0.27, blue: 0.22))
//            socialButton(icon: "apple.logo",    label: "Apple",   color: .primary)
//            socialButton(icon: "f.circle.fill", label: "Facebook",color: Color(red: 0.23, green: 0.35, blue: 0.60))
        }
    }
    // MARK: - Google Sign-In Button
        private var googleSignInButton: some View {
            Button(action: {
                DispatchQueue.main.async {
                    viewModel.signInWithGoogle()
                }
            }) {
                HStack(spacing: 10) {
                    // Google "G" logo rendered with SF colors
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                        Text("G")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.26, green: 0.52, blue: 0.96),
                                        Color(red: 0.92, green: 0.26, blue: 0.21)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
     
                    if viewModel.isGoogleLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: MangoTheme.primaryOrange))
                            .scaleEffect(0.85)
                        Text("Signing in with Google...")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    } else {
                        Text("Continue with Google")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
            .disabled(viewModel.isGoogleLoading || viewModel.authState == .loading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isGoogleLoading)
        }
 
    private func socialButton(icon: String, label: String, color: Color) -> some View {
        Button(action: { /* handle social login */ }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
    }
 
    // MARK: - Footer
    private var footerLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Button("Sign Up") {
                // Navigate to CreateAccountView
                coordinator.push(.createAccountView(viewModel: CreateAccountViewModel(authManager: FirebaseAuthManager())))
                
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(MangoTheme.primaryOrange)
        }
    }
 
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                )
        }
    }
 
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: MangoTheme.primaryOrange))
                    .scaleEffect(1.4)
                Text("Signing you in...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity)
    }
 
    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(MangoTheme.headerGradient)
                        .frame(width: 70, height: 70)
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Welcome Back!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("You're signed in to Mango 🥭")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(36)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
 
    // MARK: - Alert Binding
    private var alertItem: Binding<AlertItem?> {
        Binding<AlertItem?>(
            get: {
                if case .failure(let msg) = viewModel.authState {
                    return AlertItem(message: msg)
                }
                return nil
            },
            set: { _ in viewModel.resetState() }
        )
    }
}
 
// MARK: - Preview
#Preview {
    NavigationStack {
        LoginView(viewModel: LoginViewModel(authManager: FirebaseAuthManager()))
    }
}
