//
//  FirestoreManager.swift
//  DisasesClassificationApp
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createUserDocument(user: User) async throws {
        let userData: [String: Any] = [
            "id": user.uid,
            "email": user.email ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users").document(user.uid).setData(userData, merge: true)
    }
}
