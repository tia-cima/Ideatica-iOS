//
//  HomeView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct IdeasView: View {
    @StateObject private var viewModel = IdeaListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.ideas) { idea in
                    NavigationLink(destination: IdeaDetailView(idea: idea)) {
                        CardView(title: idea.title, topic: idea.topic)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(UIColor.secondarySystemBackground))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                    )
                }
            }
            .listStyle(.plain)
            .navigationTitle("All Ideas")
            .task {
                await viewModel.fetchIdeas()
            }
        }

    }

    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let output = DateFormatter()
            output.dateStyle = .medium
            output.timeStyle = .short
            return output.string(from: date)
        }
        return iso
    }
}
