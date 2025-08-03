//
//  HomeView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct MyIdeasView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var viewModel = MyIdeaListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if let token = authService.token {
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
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 0)
                            }
                        }
                        .padding(.top)
                    }
                    .navigationTitle("My Ideas")
                    .task {
                        if let token = authService.token {
                            await viewModel.fetchIdeas(token: token)
                        }
                    }
                    .onReceive(authService.$token.compactMap { $0 }) { token in
                        Task {
                            await viewModel.fetchIdeas(token: token)
                        }
                    }
                } else {
                    LoginPromptView(authService: authService)
                }
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
