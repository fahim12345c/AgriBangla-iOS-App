import SwiftUI

struct ChatHomeView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    @StateObject private var lm = LocalizationManager.shared

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let bgColor = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if viewModel.messages.isEmpty {
                emptyStateView
            } else {
                messagesList
            }

            inputBar
        }
        .background(bgColor)
        .onTapGesture { isInputFocused = false }
    }

    private var headerView: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .font(.title2)
                .foregroundColor(brandGreen)
            Text("কৃষি সহায়ক")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "message.fill")
                .font(.system(size: 56))
                .foregroundColor(brandGreen.opacity(0.4))
            Text("যেকোনো কৃষি প্রশ্ন করুন")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            Text("ফসল, রোগ, আবহাওয়া, সার\nসব বিষয়ে জানতে পারবেন")
                .font(.system(size: 15))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        messageBubble(message)
                            .id(message.id)
                    }

                    if viewModel.isLoading {
                        loadingIndicator
                            .id("loading")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                scrollToBottom(proxy)
            }
            .onChange(of: viewModel.isLoading) { loading in
                if loading { scrollToBottom(proxy) }
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.isLoading {
                proxy.scrollTo("loading", anchor: .bottom)
            } else {
                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            }
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user {
                Spacer()
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.leading, 40)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 12))
                            .foregroundColor(brandGreen)
                        Text("কৃষি সহায়ক")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(brandGreen)
                    }
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.trailing, 40)
                Spacer()
            }
        }
    }

    private var loadingIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 12))
                .foregroundColor(brandGreen)
            Text("উত্তর আসছে...")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            ProgressView()
                .scaleEffect(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 8)
        .id("loading")
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                TextField(lm.localized("chat_placeholder"), text: $viewModel.inputText)
                    .font(.system(size: 16))
                    .focused($isInputFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(brandGreen.opacity(0.3), lineWidth: 1)
                    )
                    .disabled(viewModel.isLoading)
                    .onSubmit { viewModel.sendMessage() }

                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(
                            viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading
                            ? brandGreen.opacity(0.4)
                            : brandGreen
                        )
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
        }
        .keyboardAdaptive()
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .ignoresSafeArea(.keyboard)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
                let value = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                keyboardHeight = value?.height ?? 0
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptive())
    }
}

#Preview {
    ChatHomeView()
}
