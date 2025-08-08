//
//  Message.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 08/08/25.
//

import Foundation

struct Message: Codable {
    let conversationId: UUID
    let messageId: UUID
    let senderId: UUID
    let content: String
    let messageTimestamp: String
}
