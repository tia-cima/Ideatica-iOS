//
//  IdeaListViewModel.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

// ViewModels/IdeaListViewModel.swift
import Foundation

@MainActor
class IdeaListViewModel: ObservableObject {
    @Published var ideas: [Idea] = []

    func fetchIdeas() async {
        guard let url = URL(string: "http://localhost:3000/api/public/idea/all") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Idea].self, from: data)
            self.ideas = decoded
        } catch {
            print("Failed to fetch ideas: \(error)")
        }
    }
}
