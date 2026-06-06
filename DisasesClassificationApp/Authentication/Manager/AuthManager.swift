//
//  AuthService.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import Foundation
import Combine
import FirebaseAuth

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isLoggedIn = user != nil
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}
 
// MARK: - AuthError
enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case networkError
    case unknown
 
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse: return "This email address is already registered."
        case .networkError:      return "A network error occurred. Please try again."
        case .unknown:           return "Something went wrong. Please try again."
        }
    }
}
