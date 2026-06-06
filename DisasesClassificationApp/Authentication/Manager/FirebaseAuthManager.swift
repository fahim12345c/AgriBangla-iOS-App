//
//  FirebaseAuthManager.swift
//  DisasesClassificationApp
//
//  Created by fahim on 5/5/26.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthManager {
    
       func signUp(email: String, password: String) async throws -> AuthDataResult {
            return try await Auth.auth().createUser(withEmail: email, password: password)
        }
        
        func login(email: String, password: String) async throws -> AuthDataResult {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        }
        
        func logout() throws {
            try Auth.auth().signOut()
        }
}
