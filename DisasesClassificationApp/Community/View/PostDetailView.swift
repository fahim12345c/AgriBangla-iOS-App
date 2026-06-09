import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PostDetailView: View {
    let post: CommunityPost
    var onDelete: (() -> Void)?
    @StateObject private var viewModel: PostDetailViewModel
    @StateObject private var lm = LocalizationManager.shared
    @State private var commentText = ""
    @State private var showDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    init(post: CommunityPost, onDelete: (() -> Void)? = nil) {
        self.post = post
        self.onDelete = onDelete
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    postSection
                    reactionsSection
                    commentsSection
                }
                .padding(16)
            }
            .background(bgColor)

            commentInputBar
        }
        .navigationTitle(lm.localized("community_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if post.userId == Auth.auth().currentUser?.uid {
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .confirmationDialog(lm.localized("community_delete_confirm"), isPresented: $showDeleteConfirm) {
            Button(lm.localized("community_delete"), role: .destructive) {
                onDelete?()
                dismiss()
            }
            Button(lm.localized("community_cancel"), role: .cancel) { }
        } message: {
            LText("community_delete_message")
        }
        .onAppear { viewModel.loadData() }
    }

    private var postSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(brandGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(post.date, style: .date)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            Text(post.text)
                .font(.system(size: 16))

            if let url = post.imageURL, !url.isEmpty {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Color.gray.opacity(0.2)
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    case .empty:
                        Color.gray.opacity(0.1)
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(ProgressView())
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var reactionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reactions")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                ForEach(ReactionType.allCases, id: \.rawValue) { type in
                    Button(action: { viewModel.toggleReaction(type) }) {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 14))
                            Text(type.label)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.myReaction == type
                            ? brandGreen.opacity(0.15)
                            : Color(.secondarySystemBackground)
                        )
                        .foregroundColor(
                            viewModel.myReaction == type ? brandGreen : .primary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(
                                    viewModel.myReaction == type ? brandGreen.opacity(0.4) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comments (\(viewModel.comments.count))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.comments.isEmpty {
                Text("No comments yet")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.comments) { comment in
                        commentRow(comment)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(brandGreen)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(comment.userName)
                        .font(.system(size: 13, weight: .semibold))
                    Text(comment.date, style: .relative)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Text(comment.text)
                    .font(.system(size: 14))
            }
        }
        .padding(10)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var commentInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                TextField(lm.localized("community_comment_placeholder"), text: $commentText)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())

                Button(action: {
                    let text = commentText.trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return }
                    viewModel.addComment(text)
                    commentText = ""
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(
                            commentText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? brandGreen.opacity(0.4)
                            : brandGreen
                        )
                }
                .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    NavigationStack {
        PostDetailView(
            post: CommunityPost(
                id: "preview-1",
                userId: "1",
                userName: "Farmer",
                text: "Test post",
                imageURL: nil,
                timestamp: Timestamp(date: Date()),
                reactionCount: 0,
                commentCount: 0
            )
        )
    }
}
