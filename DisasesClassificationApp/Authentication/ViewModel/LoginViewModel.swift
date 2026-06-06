//
//  LoginViewModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 5/5/26.
//

import Foundation
import Combine
import FirebaseAuth
import UIKit

// MARK: - LoginViewModel
@MainActor
final class LoginViewModel: ObservableObject, Identifiable {

    // MARK: - Input Fields
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - UI State
    @Published var isPasswordVisible: Bool = false
    @Published var authState: AuthState = .idle
    @Published var rememberMe: Bool = false
    @Published var isGoogleLoading: Bool = false
    @Published var showForgotPasswordAlert = false
    @Published var forgotPasswordEmail = ""

    // MARK: - Field-level Errors
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil

    private let authManager: FirebaseAuthManager

    init(authManager: FirebaseAuthManager) {
        self.authManager = authManager
    }

    // MARK: - Computed
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    // MARK: - Login

    func login() {
        Task { @MainActor in
            guard await validate() else { return }
            await performLogin()
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle() {
        Task { @MainActor in
            await performGoogleSignIn()
        }
    }

    // MARK: - Password Reset
    func sendPasswordReset() {
        let email = forgotPasswordEmail.trimmingCharacters(in: .whitespaces)
        guard !email.isEmpty else { return }
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)
                showForgotPasswordAlert = false
                authState = .success
            } catch {
                authState = .failure(error.localizedDescription)
            }
        }
    }

    // MARK: - Real-time Field Validation
    func validateEmail() {
        Task { @MainActor in
            await Task.yield()
            emailError = nil
            let trimmed = email.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                emailError = "Email address is required."
            } else if !isValidEmail(trimmed) {
                emailError = "Please enter a valid email address."
            }
        }
    }

    func validatePassword() {
        Task { @MainActor in
            await Task.yield()
            passwordError = nil
            if password.isEmpty {
                passwordError = "Password is required."
            } else if password.count < 6 {
                passwordError = "Password must be at least 6 characters."
            }
        }
    }

    func resetState() {
        Task { @MainActor in
            await Task.yield()
            authState = .idle
        }
    }

    // MARK: - Private — Validation
    private func validate() async -> Bool {
        await Task.yield()

        emailError = nil
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            emailError = "Email address is required."
        } else if !isValidEmail(trimmed) {
            emailError = "Please enter a valid email address."
        }

        passwordError = nil
        if password.isEmpty {
            passwordError = "Password is required."
        } else if password.count < 6 {
            passwordError = "Password must be at least 6 characters."
        }

        return emailError == nil && passwordError == nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    // MARK: - Private — Email Login
    private func performLogin() async {
        authState = .loading
        do {
            let result = try await authManager.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            print("✅ User logged in:", result.user.uid)
            authState = .success
        } catch let error as NSError {
            authState = .failure(firebaseErrorMessage(error))
        }
    }

    // MARK: - Private — Google Sign-In
    private func performGoogleSignIn() async {
        guard let topVC = UIApplication.shared.topViewController else {
            authState = .failure("Unable to present Google Sign-In. Please try again.")
            return
        }

        isGoogleLoading = true
        defer { isGoogleLoading = false }

        do {
            try await GoogleSignInManager.shared.signIn(presenting: topVC)
            authState = .success
        } catch let error as GoogleSignInError {
            if case .cancelled = error { return }
            authState = .failure(error.localizedDescription)
        } catch let nsError as NSError {
            if nsError.code == 0 { return }
            authState = .failure(firebaseErrorMessage(nsError))
        }
    }

    private func firebaseErrorMessage(_ error: NSError) -> String {
        switch error.code {
        case 17004, 17009: return "Incorrect email or password. Please try again."
        case 17008:        return "The email address is badly formatted."
        case 17011:        return "No account found with this email. Please sign up first."
        case 17010:        return "Too many failed attempts. Please try again later."
        case 17020:        return "Network error. Please check your connection."
        case 17999:        return "Authentication not configured. Enable it in Firebase Console → Authentication → Sign-in method."
        default:           return "Error (\(error.code)): \(error.localizedDescription)"
        }
    }
}

