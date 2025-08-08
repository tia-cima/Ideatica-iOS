//
//  Conversation.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 08/08/25.
//

import Foundation

struct Conversation: Codable, Identifiable {
    let id: UUID
    let title: String
    let participantIds: Set<String>
    let lastMessageAt: String?
}
