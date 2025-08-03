//
//  MainView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI
import Auth0

struct MainView: View {
    @State var user: User?

    var body: some View {
        if let user = self.user {
            VStack {
                ProfileView(user: user)
                Button("Logout", action: self.logout)
            }
        } else {
            VStack {
                HeroView()
                Button("Login", action: self.login)
            }
        }
    }
}

extension MainView {
    func login() {
        Auth0
            .webAuth(clientId: "dL6N4ZAHcY2HAd3ZgHe9P9vd94MQqAFy",
                     domain: "dev-ly4vdhshyy04ftkz.eu.auth0.com")
            .scope("openid profile email")
            .audience("https://dev-ly4vdhshyy04ftkz.eu.auth0.com/userinfo")
            .redirectURL(URL(string: "ideatica://auth/callback")!)
            .start { result in
                switch result {
                case .success(let credentials):
                    self.user = User(from: credentials.idToken)
                case .failure(let error):
                    print("Login failed: \(error)")
                }
            }
    }

    func logout() {
        Auth0
            .webAuth(clientId: "dL6N4ZAHcY2HAd3ZgHe9P9vd94MQqAFy",
                     domain: "dev-ly4vdhshyy04ftkz.eu.auth0.com")
            .redirectURL(URL(string: "ideatica://auth/logout")!)
            .clearSession { result in
                switch result {
                case .success:
                    self.user = nil
                case .failure(let error):
                    print("Logout failed: \(error)")
                }
            }
    }

}
