//
//  UserService.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 06/08/25.
//

import Foundation

final class UserService {
    static let shared = UserService()
    
    private init() {}

    func createOrFetchCurrentUser(token: String, user: User, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        guard let base = URL(string: ApiConfig.baseURL),
              let url = URL(string: "/api/auth/user/me", relativeTo: base) else {
            return completion(.failure(URLError(.badURL)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = CreateUserRequest(
            email: user.email,
            username: user.username,
            name: user.name
        )

        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(URLError(.badServerResponse)))
            }

            do {
                let decoded = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
