//
//  Idea.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//
// Models/Idea.swift
import Foundation

struct Idea: Identifiable, Decodable {
    let id: String
    let title: String
    let topic: String
    let content: String
    let insertDate: String
    let updateDate: String?
}
