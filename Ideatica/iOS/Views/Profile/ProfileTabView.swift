//
//  ProfileTabView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//
// Views/Profile/ProfileTabView.swift

import SwiftUI

struct ProfileTabView: View {
    @ObservedObject var authService: AuthService
    @ObservedObject private var userStore = UserStore.shared

    var body: some View {
        NavigationStack {
            if let token = authService.token {
                ScrollView {
                    VStack(spacing: 24) {
                        ProfileView(userStore: userStore)

                        NavigationLink(destination: MyIdeasView(authService: authService)) {
                            Text("View My Ideas")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: .orange))
                        .padding(.horizontal)

                        Button("Logout") {
                            authService.logout()
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: .red))
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
                .navigationTitle("Profile")
            } else {
                LoginPromptView(authService: authService)
            }
        }
    }
}
