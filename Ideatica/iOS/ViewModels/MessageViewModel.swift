//
//  MessageViewModel.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 09/08/25.
//

import Foundation

final class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchMessages(conversationId: String, token: String) async {
        await MainActor.run { isLoading = true; errorMessage = nil }

        guard let url = URL(string: "\(ApiConfig.baseURLChat)/message/\(conversationId)") else {
            await MainActor.run { self.errorMessage = "Invalid URL"; self.isLoading = false }
            return
        }

        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                await MainActor.run { self.errorMessage = "Invalid server response"; self.isLoading = false }
                return
            }

            if http.statusCode == 204 {
                await MainActor.run { self.messages = []; self.isLoading = false }
                return
            }

            if http.statusCode == 200 {
                let decoded = try JSONDecoder().decode([Message].self, from: data)
                let sorted = decoded.sorted { a, b in
                    (Self.parse(a.messageTimestamp) ?? .distantPast) <
                    (Self.parse(b.messageTimestamp) ?? .distantPast)
                }
                await MainActor.run { self.messages = sorted; self.isLoading = false }
            } else {
                await MainActor.run { self.errorMessage = "Error \(http.statusCode)"; self.isLoading = false }
            }
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription; self.isLoading = false }
        }
    }

    private static func parse(_ iso: String) -> Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.date(from: iso)
    }
}
