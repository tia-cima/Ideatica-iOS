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

    var body: some View {
        if let user = authService.user {
            VStack {
                ProfileView(user: user)
                Button("Logout") {
                    authService.logout()
                }
                .padding()
            }
        } else {
            VStack {
                HeroView()
                Button("Login") {
                    authService.login()
                }
                .padding()
            }
        }
    }
}
