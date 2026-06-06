//
//  AuthenticationView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import SwiftUI

struct CreateAccountView: View {
        @StateObject var viewModel:CreateAccountViewModel
        @EnvironmentObject private var coordinator: Coordinator
        @Environment(\.dismiss) private var dismiss
     
        // Local animation states
        @State private var headerScale: CGFloat = 0.85
        @State private var formOpacity: Double = 0
        @State private var formOffset: CGFloat = 30
    var body: some View {
        
        ZStack {
            // Background
            MangoTheme.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - Header Card
                    headerCard
                        .scaleEffect(headerScale)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // MARK: - Form Section
                    formSection
                        .opacity(formOpacity)
                        .offset(y: formOffset)
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                    
                    // MARK: - Footer
                    footerLink
                        .opacity(formOpacity)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
            
            // MARK: - Loading / Success Overlay
            if viewModel.authState == .loading {
                loadingOverlay
            }
            
            if viewModel.authState == .success {
                successOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.authState) { state in
            if case .success = state {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    coordinator.replaceStack(with: .homeView)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
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
            Alert(title: Text("Error"), message: Text(item.message), dismissButton: .default(Text("OK")) {
                viewModel.resetState()
            })
        }
        
    }

// MARK: - Header Card
   private var headerCard: some View {
       ZStack {
           RoundedRectangle(cornerRadius: 24)
               .fill(MangoTheme.headerGradient)
               .shadow(color: MangoTheme.primaryOrange.opacity(0.35), radius: 16, x: 0, y: 8)

           VStack(spacing: 10) {
               // Mango icon
               ZStack {
                   Circle()
                       .fill(Color.white.opacity(0.25))
                       .frame(width: 68, height: 68)
                   Image(systemName: "person.circle.fill")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 40, height: 40)
                       .foregroundColor(.white)
               }
               .padding(.top, 28)

               Text("Join Mango")
                   .font(.system(size: 24, weight: .bold, design: .rounded))
                   .foregroundColor(.white)

               Text("Create your account to get started")
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

           // Email
           MangoTextField(
               placeholder: "Email Address",
               systemImage: "envelope",
               text: $viewModel.email,
               errorMessage: viewModel.emailError,
               onEditingChanged: { focused in
                   if !focused { viewModel.validateEmail() }
               }
           )

           // Password
           VStack(alignment: .leading, spacing: 8) {
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
               if !viewModel.password.isEmpty {
                   PasswordStrengthBar(strength: viewModel.passwordStrength)
                       .padding(.horizontal, 4)
                       .transition(.opacity.combined(with: .move(edge: .top)))
               }
           }
           .animation(.spring(response: 0.3), value: viewModel.password.isEmpty)

           // Confirm Password
           MangoTextField(
               placeholder: "Confirm Password",
               systemImage: "lock",
               text: $viewModel.confirmPassword,
               errorMessage: viewModel.confirmPasswordError,
               isSecure: true,
               isRevealed: viewModel.isConfirmPasswordVisible,
               toggleReveal: { viewModel.isConfirmPasswordVisible.toggle() },
               onEditingChanged: { focused in
                   if !focused { viewModel.validateConfirmPassword() }
               }
           )

           // Create Account Button
           createAccountButton
               .padding(.top, 8)

           // Terms note
           termsNote
       }
   }

   // MARK: - Create Account Button
   private var createAccountButton: some View {
       Button {
               UIImpactFeedbackGenerator(style: .medium).impactOccurred()
               viewModel.createAccount()   // 🔥 trigger signup
           } label: {
               ZStack {
                   RoundedRectangle(cornerRadius: 14)
                       .fill(
                           viewModel.isFormValid
                           ? MangoTheme.headerGradient
                           : LinearGradient(
                               colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                               startPoint: .leading,
                               endPoint: .trailing
                           )
                       )
                       .shadow(
                           color: viewModel.isFormValid
                           ? MangoTheme.primaryOrange.opacity(0.4)
                           : .clear,
                           radius: 8,
                           x: 0,
                           y: 4
                       )
                   
                   // 🔥 Dynamic content (text ↔ loader)
                   if viewModel.authState == .loading {
                       ProgressView()
                           .progressViewStyle(
                               CircularProgressViewStyle(tint: .white)
                           )
                   } else {
                       Text("Create Account")
                           .font(.system(size: 16, weight: .semibold, design: .rounded))
                           .foregroundColor(
                               viewModel.isFormValid ? .white : .gray
                           )
                   }
               }
               .frame(maxWidth: .infinity)
               .frame(height: 54)
           }
           .disabled(!viewModel.isFormValid || viewModel.authState == .loading)
           .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
           .scaleEffect(viewModel.isFormValid ? 1.0 : 0.98)
   }

   // MARK: - Terms Note
   private var termsNote: some View {
       Text("By creating an account, you agree to our\nTerms of Service and Privacy Policy.")
           .font(.system(size: 11))
           .foregroundColor(.gray.opacity(0.7))
           .multilineTextAlignment(.center)
   }

   // MARK: - Footer Sign In Link
   private var footerLink: some View {
       HStack(spacing: 4) {
           Text("Already have an account?")
               .font(.system(size: 14))
               .foregroundColor(.gray)
            Button("Sign In") {
                dismiss()
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
               .background(Circle().fill(Color.white).shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2))
       }
   }

   // MARK: - Loading Overlay
   private var loadingOverlay: some View {
       ZStack {
           Color.black.opacity(0.3)
               .ignoresSafeArea()
           VStack(spacing: 16) {
               ProgressView()
                   .progressViewStyle(CircularProgressViewStyle(tint: MangoTheme.primaryOrange))
                   .scaleEffect(1.4)
               Text("Creating your account...")
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
           Color.black.opacity(0.3)
               .ignoresSafeArea()
           VStack(spacing: 16) {
               ZStack {
                   Circle()
                       .fill(MangoTheme.headerGradient)
                       .frame(width: 70, height: 70)
                   Image(systemName: "checkmark")
                       .font(.system(size: 30, weight: .bold))
                       .foregroundColor(.white)
               }
               Text("Account Created!")
                   .font(.system(size: 18, weight: .bold, design: .rounded))
               Text("Welcome to Mango 🥭")
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

   // MARK: - Alert Binding Helper
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

// MARK: - Alert Item
struct AlertItem: Identifiable {
   let id = UUID()
   let message: String
}

// MARK: - Preview
#Preview {
    CreateAccountView(viewModel: CreateAccountViewModel(authManager: FirebaseAuthManager()))
}
