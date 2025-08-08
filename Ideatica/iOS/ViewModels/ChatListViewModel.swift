//
//  ChatListViewModel.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 08/08/25.
//

import Foundation

@MainActor
final class ChatListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var searchText = ""
    @Published var isLoading = false

    func fetchConversations(userId: String, token: String) async {
        guard let url = URL(string: "\(ApiConfig.baseURLChat)/conversation/all/\(userId)") else { return }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let decoded = try JSONDecoder().decode([Conversation].self, from: data)
            print(data)
            self.conversations = decoded
        } catch {
            print("Failed to fetch conversations: \(error)")
        }
    }
}
