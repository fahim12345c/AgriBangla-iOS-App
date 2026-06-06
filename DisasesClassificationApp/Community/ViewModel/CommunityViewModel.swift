import Foundation
import Combine
import UIKit
import FirebaseAuth

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var posts: [CommunityPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let communityService: CommunityService
    private let cloudinaryService: CloudinaryService

    init(
        communityService: CommunityService = .shared,
        cloudinaryService: CloudinaryService = .shared
    ) {
        self.communityService = communityService
        self.cloudinaryService = cloudinaryService
    }

    func fetchPosts() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                posts = try await communityService.fetchPosts()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func createPost(text: String, selectedImage: UIImage?) async {
        isLoading = true
        errorMessage = nil
        do {
            var imageURL: String?
            if let image = selectedImage {
                imageURL = try await cloudinaryService.uploadImage(image)
            }
            try await communityService.createPost(text: text, imageURL: imageURL)
            posts = try await communityService.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updatePost(postId: String, text: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await communityService.updatePost(postId: postId, text: text)
            posts = try await communityService.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
}

@MainActor
final class PostDetailViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var myReaction: ReactionType?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let post: CommunityPost
    private let communityService: CommunityService

    init(post: CommunityPost, communityService: CommunityService = .shared) {
        self.post = post
        self.communityService = communityService
    }

    func loadData() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                async let commentsTask = communityService.fetchComments(for: post.id)
                async let reactionTask = communityService.fetchMyReaction(for: post.id)
                let (fetchedComments, reaction) = try await (commentsTask, reactionTask)
                comments = fetchedComments
                myReaction = reaction
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func addComment(_ text: String) {
        let postId = post.id
        Task {
            do {
                try await communityService.addComment(to: postId, text: text)
                comments = try await communityService.fetchComments(for: postId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func toggleReaction(_ type: ReactionType) {
        let postId = post.id
        Task {
            do {
                try await communityService.toggleReaction(on: postId, type: type)
                myReaction = try await communityService.fetchMyReaction(for: postId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
