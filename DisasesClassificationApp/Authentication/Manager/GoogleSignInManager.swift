//
//  GoogleSignInManager.swift
//  DisasesClassificationApp
//
//  Created by fahim on 5/5/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

// MARK: - GoogleSignInManager
/// Handles the full Google Sign-In → Firebase credential exchange flow.
/// Call `signIn(presenting:)` from your ViewModel.
final class GoogleSignInManager {
    static let shared = GoogleSignInManager()
    private init() {}

    /// Signs the user in with Google and authenticates with Firebase.
    /// - Parameter viewController: The presenting UIViewController (pass from SwiftUI via UIApplication).
    /// - Returns: The authenticated Firebase `User`.
    @discardableResult
    func signIn(presenting viewController: UIViewController) async throws -> User {

        // 1. Ensure Firebase clientID is available
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleSignInError.missingClientID
        }

        // 2. Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // 3. Trigger the Google OAuth sheet
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)

        // 4. Extract tokens
        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.missingToken
        }
        let accessToken = result.user.accessToken.tokenString

        // 5. Exchange for Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )

        // 6. Sign in to Firebase
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // 7. Save to Firestore
        let displayName = authResult.user.displayName ?? ""
        let nameParts = displayName.split(separator: " ", maxSplits: 1)
        let firstName = nameParts.first.map(String.init) ?? ""
        let lastName = nameParts.dropFirst().first.map(String.init) ?? ""
        try await FirestoreManager.shared.createUserDocument(
            user: authResult.user,
            firstName: firstName,
            lastName: lastName
        )
        
        return authResult.user
    }

    /// Signs out from both Google and Firebase.
    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }
}

// MARK: - GoogleSignInError
enum GoogleSignInError: LocalizedError {
    case missingClientID
    case missingToken
    case cancelled

    var errorDescription: String? {
        switch self {
        case .missingClientID: return "Firebase is not configured correctly. Check GoogleService-Info.plist."
        case .missingToken:    return "Failed to retrieve Google ID token. Please try again."
        case .cancelled:       return "Google Sign-In was cancelled."
        }
    }
}

// MARK: - UIApplication Helper
/// Gets the topmost UIViewController for presenting the Google Sign-In sheet.
extension UIApplication {
    var topViewController: UIViewController? {
        guard let windowScene = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }
        return topVC(from: rootVC)
    }

    private func topVC(from vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController {
            return topVC(from: presented)
        }
        if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
            return topVC(from: visible)
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return topVC(from: selected)
        }
        return vc
    }
}
