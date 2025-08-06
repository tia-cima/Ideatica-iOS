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
    @Published var displayName: String? = nil
    @Published var favoriteTopic: String? = nil

    private init() {}

    func update(from response: UserResponse) {
        self.id = response.id
        self.email = response.email
        self.displayName = response.displayName
        self.favoriteTopic = response.favoriteTopic
    }

    func clear() {
        self.id = nil
        self.email = nil
        self.displayName = nil
        self.favoriteTopic = nil
    }
}
