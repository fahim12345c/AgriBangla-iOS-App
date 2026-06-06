import Foundation
import FirebaseFirestore
import FirebaseAuth

final class CommunityService {
    static let shared = CommunityService()
    private let db = Firestore.firestore()
    private let postsCollection = "posts"

    private init() {}

    // MARK: - Posts
    func fetchPosts() async throws -> [CommunityPost] {
        let snapshot = try await db.collection(postsCollection)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            guard let userId = d["userId"] as? String,
                  let userName = d["userName"] as? String,
                  let text = d["text"] as? String,
                  let timestamp = d["timestamp"] as? Timestamp else { return nil }
            return CommunityPost(
                id: doc.documentID,
                userId: userId,
                userName: userName,
                text: text,
                imageURL: d["imageURL"] as? String,
                timestamp: timestamp,
                reactionCount: d["reactionCount"] as? Int ?? 0,
                commentCount: d["commentCount"] as? Int ?? 0
            )
        }
    }

    func createPost(text: String, imageURL: String?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userName = Auth.auth().currentUser?.displayName ?? "Farmer"
        let data: [String: Any] = [
            "userId": userId,
            "userName": userName,
            "text": text,
            "imageURL": imageURL as Any,
            "timestamp": Timestamp(date: Date()),
            "reactionCount": 0,
            "commentCount": 0
        ]
        _ = try await db.collection(postsCollection).addDocument(data: data)
    }

    func updatePost(postId: String, text: String) async throws {
        try await db.collection(postsCollection).document(postId).updateData([
            "text": text
        ])
    }

    // MARK: - Comments
    func fetchComments(for postId: String) async throws -> [Comment] {
        let snapshot = try await db.collection(postsCollection)
            .document(postId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let d = doc.data()
            guard let userId = d["userId"] as? String,
                  let userName = d["userName"] as? String,
                  let text = d["text"] as? String,
                  let timestamp = d["timestamp"] as? Timestamp else { return nil }
            return Comment(
                id: doc.documentID,
                postId: postId,
                userId: userId,
                userName: userName,
                text: text,
                timestamp: timestamp
            )
        }
    }

    func addComment(to postId: String, text: String) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userName = Auth.auth().currentUser?.displayName ?? "Farmer"
        let data: [String: Any] = [
            "postId": postId,
            "userId": userId,
            "userName": userName,
            "text": text,
            "timestamp": Timestamp(date: Date())
        ]
        _ = try await db.collection(postsCollection)
            .document(postId)
            .collection("comments")
            .addDocument(data: data)

        let postRef = db.collection(postsCollection).document(postId)
        try await postRef.updateData(["commentCount": FieldValue.increment(Int64(1))])
    }

    // MARK: - Reactions
    func fetchMyReaction(for postId: String) async throws -> ReactionType? {
        guard let userId = Auth.auth().currentUser?.uid else { return nil }
        let snapshot = try await db.collection(postsCollection)
            .document(postId)
            .collection("reactions")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        guard let doc = snapshot.documents.first else { return nil }
        let d = doc.data()
        guard let rawType = d["type"] as? String,
              let type = ReactionType(rawValue: rawType) else { return nil }
        return type
    }

    func toggleReaction(on postId: String, type: ReactionType) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let reactionsRef = db.collection(postsCollection)
            .document(postId)
            .collection("reactions")

        let existing = try await reactionsRef
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        let postRef = db.collection(postsCollection).document(postId)

        if let doc = existing.documents.first {
            let d = doc.data()
            let existingType = (d["type"] as? String).flatMap(ReactionType.init(rawValue:))
            if existingType == type {
                try await doc.reference.delete()
                try await postRef.updateData(["reactionCount": FieldValue.increment(Int64(-1))])
            } else {
                try await doc.reference.updateData(["type": type.rawValue, "timestamp": Timestamp(date: Date())])
            }
        } else {
            let data: [String: Any] = [
                "postId": postId,
                "userId": userId,
                "type": type.rawValue,
                "timestamp": Timestamp(date: Date())
            ]
            _ = try await reactionsRef.addDocument(data: data)
            try await postRef.updateData(["reactionCount": FieldValue.increment(Int64(1))])
        }
    }
}
