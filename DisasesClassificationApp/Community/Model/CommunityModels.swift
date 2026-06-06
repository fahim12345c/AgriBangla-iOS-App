import Foundation
import FirebaseFirestore

struct CommunityPost: Identifiable {
    let id: String
    let userId: String
    let userName: String
    let text: String
    let imageURL: String?
    let timestamp: Timestamp
    var reactionCount: Int
    var commentCount: Int

    var date: Date { timestamp.dateValue() }

    init(id: String, userId: String, userName: String, text: String, imageURL: String?, timestamp: Timestamp, reactionCount: Int, commentCount: Int) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.imageURL = imageURL
        self.timestamp = timestamp
        self.reactionCount = reactionCount
        self.commentCount = commentCount
    }
}

struct Comment: Identifiable {
    let id: String
    let postId: String
    let userId: String
    let userName: String
    let text: String
    let timestamp: Timestamp

    var date: Date { timestamp.dateValue() }

    init(id: String, postId: String, userId: String, userName: String, text: String, timestamp: Timestamp) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
    }
}

struct PostReaction: Identifiable {
    let id: String
    let postId: String
    let userId: String
    let type: ReactionType
    let timestamp: Timestamp

    init(id: String, postId: String, userId: String, type: ReactionType, timestamp: Timestamp) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.type = type
        self.timestamp = timestamp
    }
}

enum ReactionType: String, Codable, CaseIterable {
    case like = "like"
    case helpful = "helpful"
    case thanks = "thanks"

    var icon: String {
        switch self {
        case .like: return "hand.thumbsup.fill"
        case .helpful: return "heart.fill"
        case .thanks: return "sparkles"
        }
    }

    var label: String {
        switch self {
        case .like: return "👍 Like"
        case .helpful: return "❤️ Helpful"
        case .thanks: return "✨ Thanks"
        }
    }
}

struct UserPostData: Codable {
    let displayName: String
    let email: String
}
