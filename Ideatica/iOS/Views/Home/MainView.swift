//
//  MainView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI
import Auth0

struct MainView: View {
    @State private var selectedTab = 0
    @StateObject private var authService = AuthService()

    var body: some View {
        TabView(selection: $selectedTab) {
            IdeasView()
                .tabItem {
                    Label("Ideas", systemImage: "lightbulb")
                }
                .tag(0)
            
            MyIdeasView(authService: authService)
                .tabItem {
                    Label("My Ideas", systemImage: "doc.text")
                }
                .tag(0)

            PostIdeaView()
                .tabItem {
                    Label("New Idea", systemImage: "plus.square")
                }
                .tag(1)

            ProfileTabView(authService: authService)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .onAppear {
            authService.restoreSession()
        }
    }
}

