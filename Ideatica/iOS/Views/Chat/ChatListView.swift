//
//  ChatListView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 08/08/25.
//

// ChatListView.swift
import SwiftUI

struct ChatListView: View {
    @ObservedObject var authService: AuthService
    @EnvironmentObject var userStore: UserStore
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let token = authService.token, let userId = userStore.id {
                    VStack {
                        if viewModel.isLoading && viewModel.conversations.isEmpty {
                            ProgressView().padding()
                        }
                        
                        List(viewModel.conversations) { convo in
                            NavigationLink {
                                Text("Chat for \(convo.id)")
                                    .navigationTitle("Chat")
                            } label: {
                                ConversationRow(convo: convo)
                            }
                        }
                        .listStyle(.plain)
                    }
                    .navigationTitle("Chats")
                    .task {
                        await viewModel.fetchConversations(userId: userId, token: token)
                    }
                    .onReceive(authService.$token.compactMap { $0 }) { newToken in
                        Task {
                            await viewModel.fetchConversations(userId: userId, token: newToken)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchConversations(userId: userId, token: token)
                    }
                } else {
                    LoginPromptView(authService: authService)
                }
            }
        }
    }
}

private struct ConversationRow: View {
    let convo: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Conversation \(convo.id)")
                .font(.headline)

            if let last = convo.lastMessageAt {
                HStack(spacing: 6) {
                    Text(relativeTime(last))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No messages yet")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
    }

    private func relativeTime(_ iso: String) -> String {
        let fmt = ISO8601DateFormatter()
        guard let date = fmt.date(from: iso) else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: date, relativeTo: Date())
    }
}
