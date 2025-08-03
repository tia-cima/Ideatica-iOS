//
//  PostIdeaView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct PostIdeaView: View {
    @ObservedObject var authService: AuthService
    
    @State private var title = ""
    @State private var topic = ""
    @State private var content = ""
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Topic")) {
                    TextField("Enter topic", text: $topic)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(height: 150)
                }
                
                Section {
                    Button("Submit Idea") {
                        Task {
                            await submitIdea()
                        }
                    }
                    .disabled(authService.token == nil)
                }
                
                if !message.isEmpty {
                    Section {
                        Text(message)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Post New Idea")
        }
    }
    
    func submitIdea() async {
        guard let token = authService.token else {
            message = "You're not authenticated."
            return
        }
        
        guard let url = URL(string: "http://localhost:3000/api/auth/idea/new") else {
            message = "Invalid backend URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let idea = [
            "title": title,
            "topic": topic,
            "content": content
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: idea, options: [])
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    message = "Idea posted successfully!"
                    title = ""
                    topic = ""
                    content = ""
                } else {
                    message = "Failed with status code: \(httpResponse.statusCode)"
                }
            }
        } catch {
            message = "Request failed: \(error.localizedDescription)"
        }
    }
}
