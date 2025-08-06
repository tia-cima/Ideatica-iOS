//
//  UserResponse.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 06/08/25.
//

import Foundation

struct UserResponse: Codable {
    let id: String
    let email: String
    let displayName: String
    let favoriteTopic: String?
    let insertDate: String
    let updateDate: String
}
