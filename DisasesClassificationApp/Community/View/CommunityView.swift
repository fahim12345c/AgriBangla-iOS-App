import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false
    @State private var editingPost: CommunityPost?
    @State private var editText = ""

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading...")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                } else if let error = viewModel.errorMessage {
                    errorState(error)
                } else if viewModel.posts.isEmpty {
                    emptyState
                } else {
                    postsList
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showCreatePost = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(brandGreen)
                                .clipShape(Circle())
                                .shadow(color: brandGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Community")
            .sheet(isPresented: $showCreatePost) {
                CreatePostView { text, image in
                    Task { await viewModel.createPost(text: text, selectedImage: image) }
                }
            }
            .sheet(item: $editingPost) { post in
                editSheet(post)
            }
            .onAppear { viewModel.fetchPosts() }
        }
    }

    private func editSheet(_ post: CommunityPost) -> some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextEditor(text: $editText)
                    .font(.system(size: 16))
                    .padding(12)
                    .frame(height: 200)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(brandGreen.opacity(0.3), lineWidth: 1)
                    )
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.95, green: 0.97, blue: 0.95).ignoresSafeArea())
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingPost = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let text = editText
                        editingPost = nil
                        Task { await viewModel.updatePost(postId: post.id ?? "", text: text) }
                    }
                    .fontWeight(.semibold)
                    .disabled(editText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { editText = post.text }
        }
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Try Again") { viewModel.fetchPosts() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(brandGreen)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(brandGreen.opacity(0.1))
                .clipShape(Capsule())
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 56))
                .foregroundColor(brandGreen.opacity(0.4))
            Text("No posts yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            Text("Be the first to share with the community")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
            Spacer()
        }
    }

    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(viewModel.posts) { post in
                    NavigationLink(destination: PostDetailView(post: post, onDelete: {
                        viewModel.deletePost(postId: post.id)
                    })) {
                        PostCardView(
                            post: post,
                            isOwner: post.userId == viewModel.currentUserId,
                            onEdit: {
                                editText = post.text
                                editingPost = post
                            },
                            onDelete: {
                                viewModel.deletePost(postId: post.id)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .refreshable { viewModel.fetchPosts() }
    }
}

struct PostCardView: View {
    let post: CommunityPost
    var isOwner: Bool = false
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    @State private var showDeleteConfirm = false

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(brandGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(post.date, style: .relative)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                if isOwner {
                    HStack(spacing: 4) {
                        Button(action: { onEdit?() }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(brandGreen.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        Button(action: { showDeleteConfirm = true }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .confirmationDialog("Delete Post?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) { onDelete?() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete your post.")
            }

            Text(post.text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineLimit(4)

            if let url = post.imageURL, !url.isEmpty {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Color.gray.opacity(0.2)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    case .empty:
                        Color.gray.opacity(0.1)
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(ProgressView())
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            HStack(spacing: 16) {
                Label("\(post.reactionCount)", systemImage: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Label("\(post.commentCount)", systemImage: "message.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    CommunityView()
}
