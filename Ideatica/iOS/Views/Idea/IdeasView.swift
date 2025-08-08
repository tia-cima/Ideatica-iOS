//
//  HomeView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct IdeasView: View {
    @StateObject private var viewModel = IdeaListViewModel()
    @ObservedObject var authService: AuthService

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
            .safeAreaInset(edge: .bottom) {
                NavigationLink(destination: PostIdeaView(authService: authService, selectedTab: .constant(0))) {
                    Text("New Idea")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(backgroundColor: .orange))
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
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
