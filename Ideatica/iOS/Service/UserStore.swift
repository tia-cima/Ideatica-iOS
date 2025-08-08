//
//  UserStore.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 06/08/25.
//

import Foundation
import Combine

final class UserStore: ObservableObject {
    static let shared = UserStore()

    @Published var id: String? = nil
    @Published var email: String? = nil
    @Published var username: String? = nil
    @Published var name: String? = nil
    @Published var picture: String? = nil

    private init() {}

    func update(from response: UserResponse, picture: String?) {
        self.id = response.id
        self.email = response.email
        self.username = response.username
        self.name = response.name
        self.picture = picture
    }


    func clear() {
        self.id = nil
        self.email = nil
        self.username = nil
        self.name = nil
        self.picture = nil
    }
    
    func debugPrint() {
        print("""
        UserStore:
        - ID: \(id ?? "nil")
        - Email: \(email ?? "nil")
        - Username: \(username ?? "nil")
        - Name: \(name ?? "nil")
        - Picture: \(picture ?? "nil")
        """)
    }

}
