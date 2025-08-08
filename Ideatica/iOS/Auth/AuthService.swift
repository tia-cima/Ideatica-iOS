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
                    
                    print("TOKEN ID \n\n")
                    print(credentials.idToken)
                    
                    print("\n\nTOKEN ACCESS \n\n")
                    print(credentials.accessToken)
                    
                    let token = credentials.accessToken
                    guard let decodedUser = User(from: credentials.idToken) else {
                        print("Failed to decode ID token into User")
                        return
                    }
                    
                    print("\n\nDECODED USER \n\n")
                    print(decodedUser)

                    
                    self.token = token
                    self.credentialsManager.store(credentials: credentials)

                    UserService.shared.createOrFetchCurrentUser(token: token, user: decodedUser) { result in
                        switch result {
                        case .success(let backendUser):
                            DispatchQueue.main.async {
                                print("User data fetched from backend: \(backendUser)")
                                UserStore.shared.update(from: backendUser, picture: decodedUser.picture)
                                print("UserStore updated with backend user")
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

    func restoreSession() {
        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                
                let token = credentials.accessToken
                if token.isEmpty {
                    print("No access token")
                    return
                }

                let authUser = User(from: credentials.idToken)
                DispatchQueue.main.async {
                    self.token = token
                }

                UserService.shared.getCurrentUser(token: token) { result in
                    switch result {
                    case .success(let backendUser):
                        DispatchQueue.main.async {
                            print("Restored user from backend: \(backendUser)")
                            UserStore.shared.update(from: backendUser, picture: authUser?.picture)
                            print("UserStore restored with backend user")
                        }
                    case .failure(let error):
                        print("Failed to fetch user from /sub: \(error)")
                    }
                }

            case .failure(let error):
                print("No valid session: \(error)")
            }
        }
    }
}
