//
//  CreateAccountViewModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import Foundation
import Combine
import FirebaseAuth

// MARK: - Validation Error
enum ValidationError: LocalizedError {
    case emptyEmail
    case invalidEmail
    case emptyPassword
    case weakPassword
    case emptyConfirmPassword
    case passwordMismatch

    var errorDescription: String? {
        switch self {
        case .emptyEmail:           return "Email address is required."
        case .invalidEmail:         return "Please enter a valid email address."
        case .emptyPassword:        return "Password is required."
        case .weakPassword:         return "Password must be at least 8 characters, include an uppercase letter, a number, and a special character."
        case .emptyConfirmPassword: return "Please confirm your password."
        case .passwordMismatch:     return "Passwords do not match."
        }
    }
}

// MARK: - Auth State
enum AuthState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

// MARK: - CreateAccountViewModel
@MainActor
final class CreateAccountViewModel: ObservableObject, Identifiable {

    // MARK: - Identifiable
    let id: UUID = UUID()

    // MARK: - Published Input Fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()

    // MARK: - Published UI State
    @Published var isPasswordVisible: Bool = false
    @Published var isConfirmPasswordVisible: Bool = false
    @Published var authState: AuthState = .idle

    // MARK: - Field-level Error Messages
    @Published var firstNameError: String? = nil
    @Published var lastNameError: String? = nil
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil

    private let authManager: FirebaseAuthManager


    init(authManager: FirebaseAuthManager) {
        self.authManager = authManager
    }

    // MARK: - Computed: Is form valid
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }

    // MARK: - Password Strength
    var passwordStrength: PasswordStrength {
        evaluatePasswordStrength(password)
    }

    // MARK: - Create Account
    func createAccount() {
        Task { @MainActor in
            guard await validate() else { return }
            await performRegistration()
        }
    }

    // MARK: - Real-time Field Validation
    func validateFirstName() {
        firstNameError = firstName.trimmingCharacters(in: .whitespaces).isEmpty ? "First name is required." : nil
    }

    func validateLastName() {
        lastNameError = lastName.trimmingCharacters(in: .whitespaces).isEmpty ? "Last name is required." : nil
    }

    func validateEmail() {
        Task { @MainActor in
            await Task.yield()
            emailError = nil
            let trimmed = email.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                emailError = ValidationError.emptyEmail.errorDescription
            } else if !isValidEmail(trimmed) {
                emailError = ValidationError.invalidEmail.errorDescription
            }
        }
    }

    func validatePassword() {
        Task { @MainActor in
            await Task.yield()
            passwordError = nil
            if password.isEmpty {
                passwordError = ValidationError.emptyPassword.errorDescription
            } else if !isStrongPassword(password) {
                passwordError = ValidationError.weakPassword.errorDescription
            }
            if !confirmPassword.isEmpty {
                await Task.yield()
                confirmPasswordError = nil
                if confirmPassword != password {
                    confirmPasswordError = ValidationError.passwordMismatch.errorDescription
                }
            }
        }
    }

    func validateConfirmPassword() {
        Task { @MainActor in
            await Task.yield()
            confirmPasswordError = nil
            if confirmPassword.isEmpty {
                confirmPasswordError = ValidationError.emptyConfirmPassword.errorDescription
            } else if confirmPassword != password {
                confirmPasswordError = ValidationError.passwordMismatch.errorDescription
            }
        }
    }

    // MARK: - Clear state
    func resetState() {
        authState = .idle
    }

    // MARK: - Private Helpers
    private func validate() async -> Bool {
        await Task.yield()

        firstNameError = firstName.trimmingCharacters(in: .whitespaces).isEmpty ? "First name is required." : nil
        lastNameError = lastName.trimmingCharacters(in: .whitespaces).isEmpty ? "Last name is required." : nil

        emailError = nil
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            emailError = ValidationError.emptyEmail.errorDescription
        } else if !isValidEmail(trimmed) {
            emailError = ValidationError.invalidEmail.errorDescription
        }

        passwordError = nil
        if password.isEmpty {
            passwordError = ValidationError.emptyPassword.errorDescription
        } else if !isStrongPassword(password) {
            passwordError = ValidationError.weakPassword.errorDescription
        }

        confirmPasswordError = nil
        if confirmPassword.isEmpty {
            confirmPasswordError = ValidationError.emptyConfirmPassword.errorDescription
        } else if confirmPassword != password {
            confirmPasswordError = ValidationError.passwordMismatch.errorDescription
        }

        return firstNameError == nil && lastNameError == nil && emailError == nil && passwordError == nil && confirmPasswordError == nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func isStrongPassword(_ pwd: String) -> Bool {
        let hasMinLength = pwd.count >= 8
        let hasUppercase = pwd.range(of: "[A-Z]",        options: .regularExpression) != nil
        let hasDigit     = pwd.range(of: "[0-9]",        options: .regularExpression) != nil
        let hasSpecial   = pwd.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        return hasMinLength && hasUppercase && hasDigit && hasSpecial
    }

    private func evaluatePasswordStrength(_ pwd: String) -> PasswordStrength {
        guard !pwd.isEmpty else { return .none }
        var score = 0
        if pwd.count >= 8  { score += 1 }
        if pwd.count >= 12 { score += 1 }
        if pwd.range(of: "[A-Z]",        options: .regularExpression) != nil { score += 1 }
        if pwd.range(of: "[0-9]",        options: .regularExpression) != nil { score += 1 }
        if pwd.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { score += 1 }
        switch score {
        case 0...1: return .weak
        case 2...3: return .fair
        case 4:     return .good
        default:    return .strong
        }
    }

    // MARK: - Firebase Registration
    private func performRegistration() async {
        authState = .loading
        do {
            let result = try await authManager.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            print("✅ User created:", result.user.uid)

            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = firstName.trimmingCharacters(in: .whitespaces)
            try await changeRequest.commitChanges()

            // Save to Firestore
            try await FirestoreManager.shared.createUserDocument(
                user: result.user,
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                dateOfBirth: dateOfBirth
            )

            authState = .success
        } catch let error as NSError {
            authState = .failure(firebaseErrorMessage(error))
        }
    }

    private func firebaseErrorMessage(_ error: NSError) -> String {
        switch error.code {
        case 17007: return "This email is already registered. Please sign in instead."
        case 17008: return "The email address is badly formatted."
        case 17026: return "Password must be at least 6 characters."
        case 17010: return "Too many attempts. Please try again later."
        case 17020: return "Network error. Please check your connection."
        case 17999: return "Email/Password sign-in is not enabled. Go to Firebase Console → Authentication → Sign-in method → Enable Email/Password."
        default:    return "Error (\(error.code)): \(error.localizedDescription)"
        }
    }
}
