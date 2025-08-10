//
//  ApiConfig.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import Foundation

struct ApiConfig {
    static let host = "192.168.1.24:8080"
    static let baseURL = "http://" + host + "/api"
    static let wsBaseURL = "ws://" + host
    static let wsURLChat = wsBaseURL + "/ws/chat"
}
