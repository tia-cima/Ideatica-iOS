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
            IdeasView(authService: authService)
                .tabItem {
                    Label("Ideas", systemImage: "lightbulb")
                }
                .tag(0)
            
            ChatListView(authService: authService)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(1)

            ProfileTabView(authService: authService)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .environmentObject(UserStore.shared)
        .onAppear {
            authService.restoreSession()
        }
    }
}

