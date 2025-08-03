//
//  IdeaListViewModel.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

// ViewModels/IdeaListViewModel.swift
import Foundation

@MainActor
class MyIdeaListViewModel: ObservableObject {
    @Published var ideas: [Idea] = []

    func fetchIdeas(token: String) async {
        guard let url = URL(string: "\(ApiConfig.baseURL)/auth/idea/me/ideas") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Unauthorized or server error: \(httpResponse.statusCode)")
                    return
                }
            }

            let decoded = try JSONDecoder().decode([Idea].self, from: data)
            self.ideas = decoded
        } catch {
            print("Failed to fetch authenticated ideas: \(error)")
        }
    }
}
