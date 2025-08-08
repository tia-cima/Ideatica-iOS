//
//  AuthService.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import Foundation
import Auth0

final class AuthService: ObservableObject {
    @Published var user: User?
    @Published var token: String?
    

    private let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    func login() {
        Auth0
            .webAuth(clientId: "dL6N4ZAHcY2HAd3ZgHe9P9vd94MQqAFy",
                     domain: "dev-ly4vdhshyy04ftkz.eu.auth0.com")
            .scope("openid profile email offline_access")
            .audience("https://dev-ly4vdhshyy04ftkz.eu.auth0.com/api/v2/")
            .redirectURL(URL(string: "ideatica://auth/callback")!)
            .start { result in
                switch result {
                case .success(let credentials):
                    self.user = User(from: credentials.idToken)
                    self.token = credentials.accessToken
                    self.credentialsManager.store(credentials: credentials)
                    
                    guard let user = self.user else {
                        print("Missing user")
                        return
                    }
                    let token = credentials.accessToken
                    UserService.shared.createOrFetchCurrentUser(token: token, user: user) { result in
                        switch result {
                        case .success(let backendUser):
                            DispatchQueue.main.async {
                                UserStore.shared.update(from: backendUser)
                            }
                        case .failure(let error):
                            print("Backend user fetch failed: \(error)")
                        }
                    }

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
                    self.credentialsManager.clear()
                    self.token = nil
                    self.user = nil
                    UserStore.shared.clear()
                case .failure(let error):
                    print("Logout failed: \(error)")
                }
            }
    }
    
    func restoreSession() { // todo non funzia
        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                DispatchQueue.main.async {
                    self.user = User(from: credentials.idToken)
                    self.token = credentials.accessToken
                }

                if let user = self.user {
                    let token = credentials.accessToken
                    UserService.shared.createOrFetchCurrentUser(token: token, user: user) { result in
                        switch result {
                        case .success(let backendUser):
                            DispatchQueue.main.async {
                                UserStore.shared.update(from: backendUser)
                            }
                        case .failure(let error):
                            print("Backend user fetch failed: \(error)")
                        }
                    }
                }
            case .failure(let error):
                print("No valid session found: \(error)")
            }
        }
    }
}
