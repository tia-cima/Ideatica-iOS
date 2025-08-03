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
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.ideas) { idea in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(idea.title)
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text(idea.topic.uppercased())
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.orange)
                                .cornerRadius(6)

                            Text(idea.content)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineLimit(4)

                            Text(formatDate(idea.insertDate))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // 👈 this forces alignment
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 0)
                    }
                }
                .padding(.top)
            }
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
