//
//  MessageViewi.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 09/08/25.
//

import SwiftUI

struct MessageView: View {
    let conversationId: UUID
    let conversationTitle: String
    let token: String
    let currentUserId: String

    @StateObject private var vm = MessageViewModel()
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView().padding()
            }

            ScrollViewReader { proxy in
                ScrollView {
                    MessagesList(messages: vm.messages, currentUserId: currentUserId)
                        .padding(.vertical, 8)
                }
                .onChange(of: vm.messages.count) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
                .task {
                    await vm.fetchMessages(conversationId: conversationId.uuidString, token: token)
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
                .refreshable {
                    await vm.fetchMessages(conversationId: conversationId.uuidString, token: token)
                }
            }
        }
        .navigationTitle(conversationTitle.isEmpty ? "Chat" : conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            composer
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("Message…", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)

            Button {
                // TODO: hook up send later
                inputText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Messages List (extracted to help the compiler)
private struct MessagesList: View {
    let messages: [Message]
    let currentUserId: String

    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(messages, id: \.messageId) { msg in
                bubble(for: msg, me: currentUserId)
            }
            Color.clear.frame(height: 1).id("bottom")
        }
    }

    @ViewBuilder
    private func bubble(for msg: Message, me: String) -> some View {
        MessageBubbleView(
            text: msg.content,
            isMine: msg.senderId == me,
            timestampISO: msg.messageTimestamp
        )
        .id(msg.messageId)
        .padding(.horizontal, 12)
    }
}

private struct MessageBubbleView: View {
    let text: String
    let isMine: Bool
    let timestampISO: String

    var body: some View {
        HStack {
            if isMine { Spacer(minLength: 40) }
            VStack(alignment: .leading, spacing: 4) {
                Text(text)
                    .font(.body)

                Text(shortTime(timestampISO))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(10)
            .background(isMine ? Color.accentColor.opacity(0.15)
                               : Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            if !isMine { Spacer(minLength: 40) }
        }
    }

    private func shortTime(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: iso) {
            let out = DateFormatter()
            out.timeStyle = .short
            return out.string(from: d)
        }
        return ""
    }
}
