//
//  MessageViewi.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 09/08/25.
//

import SwiftUI

import SwiftUI

struct MessageView: View {
    let conversationId: String
    let conversationTitle: String
    let token: String
    let currentUserId: String
    let peerUserId: String     // <-- needed for SEND

    @StateObject private var vm = MessageViewModel()
    @State private var inputText = ""
    @StateObject private var ws: ChatWebSocket

    init(conversationId: String,
         conversationTitle: String,
         token: String,
         currentUserId: String,
         peerUserId: String) {
        self.conversationId = conversationId
        self.conversationTitle = conversationTitle
        self.token = token
        self.currentUserId = currentUserId
        self.peerUserId = peerUserId
        // Adjust the URL to match your WebSocketConfig
        let url = URL(string: ApiConfig.wsBaseURL + "/ws/chat")!
        _ws = StateObject(wrappedValue: ChatWebSocket(wsURL: url))
    }

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
                    await vm.fetchMessages(conversationId: conversationId, token: token)
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
                .refreshable {
                    await vm.fetchMessages(conversationId: conversationId, token: token)
                }
            }
        }
        .navigationTitle(conversationTitle.isEmpty ? "Chat" : conversationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { composer }
        .onAppear {
            ws.connect(conversationId: conversationId)
            NotificationCenter.default.addObserver(
                forName: .didReceiveChatMessage,
                object: nil,
                queue: .main
            ) { note in
                guard let text = note.userInfo?["payload"] as? String else { return }
                // Try decode KafkaMessage and append to UI
                if let data = text.data(using: .utf8),
                   let km = try? JSONDecoder().decode(IncomingKafkaMessage.self, from: data) {
                    let msg = Message(
                        conversationId: UUID(uuidString: conversationId)!,
                        messageId: UUID().uuidString, // client temp id
                        senderId: km.from,
                        content: km.content,
                        messageTimestamp: km.timestamp
                    )
                    vm.messages.append(msg)
                } else {
                    // server might send simple text acks like "Subscribed to: <id>"
                    print("WS text:", text)
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .didReceiveChatMessage, object: nil)
            ws.disconnect()
        }
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("Message…", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .onChange(of: inputText) { _, newValue in
                    let lowered = newValue.lowercased()
                    if lowered != newValue { inputText = lowered }
                }

            Button {
                let content = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !content.isEmpty else { return }
                ws.sendMessage(conversationId: conversationId,
                               from: currentUserId,
                               to: peerUserId,
                               content: content)
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
