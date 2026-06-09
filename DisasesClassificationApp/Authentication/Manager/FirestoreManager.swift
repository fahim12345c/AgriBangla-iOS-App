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

    func createUserDocument(user: User, firstName: String, lastName: String, dateOfBirth: Date? = nil) async throws {
        var userData: [String: Any] = [
            "id": user.uid,
            "email": user.email ?? "",
            "firstName": firstName,
            "lastName": lastName,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let dob = dateOfBirth {
            userData["dateOfBirth"] = Timestamp(date: dob)
        }

        try await db.collection("users").document(user.uid).setData(userData, merge: true)
    }

    func fetchUser(userId: String) async throws -> UserModel? {
        let doc = try await db.collection("users").document(userId).getDocument()
        guard doc.exists, let data = doc.data() else { return nil }
        return UserModel(
            id: userId,
            email: data["email"] as? String ?? "",
            firstName: data["firstName"] as? String,
            lastName: data["lastName"] as? String,
            profileImageURL: data["profileImageURL"] as? String,
            dateOfBirth: (data["dateOfBirth"] as? Timestamp)?.dateValue(),
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }

    func updateProfileImageURL(userId: String, url: String) async throws {
        try await db.collection("users").document(userId).setData([
            "profileImageURL": url
        ], merge: true)
    }
}
