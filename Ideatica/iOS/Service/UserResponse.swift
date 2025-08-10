//
//  UserResponse.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 06/08/25.
//

import Foundation

struct UserResponse: Codable {
    let email: String
    let username: String
    let name: String
    let insertDate: String
    let updateDate: String
}
