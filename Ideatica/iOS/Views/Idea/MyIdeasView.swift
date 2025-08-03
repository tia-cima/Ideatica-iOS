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
        Group {
            if let token = authService.token {
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
        .navigationTitle("My Ideas")
    }
}
