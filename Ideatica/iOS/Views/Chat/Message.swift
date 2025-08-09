//
//  Message.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 08/08/25.
//

import Foundation

struct Message: Codable {
    let conversationId: UUID
    let messageId: String
    let senderId: String
    let content: String
    let messageTimestamp: String
}
