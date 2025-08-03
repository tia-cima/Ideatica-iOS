//
//  PostIdeaView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct PostIdeaView: View {
    @ObservedObject var authService: AuthService
    @Binding var selectedTab: Int

    @State private var title = ""
    @State private var topic = ""
    @State private var content = ""
    @State private var message = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            if let _ = authService.token {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            Text("Title")
                                .font(.headline)
                            TextField("Enter title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Topic")
                                .font(.headline)
                            TextField("Enter topic", text: $topic)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Content")
                                .font(.headline)
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("Enter your idea...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $content)
                                    .frame(height: 150)
                                    .padding(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2))
                                    )
                            }
                        }

                        Button("Submit Idea") {
                            Task {
                                await submitIdea()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle(backgroundColor: .orange))

                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Post a new idea")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text(message),
                          dismissButton: .default(Text("OK")))
                }
            } else {
                LoginPromptView(authService: authService)
            }
        }
    }

    func submitIdea() async {
        guard let token = authService.token else {
            message = "You're not authenticated."
            showAlert = true
            return
        }

        guard let url = URL(string: "\(ApiConfig.baseURL)/auth/idea/new") else {
            message = "Invalid backend URL."
            showAlert = true
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
                    DispatchQueue.main.async {
                        selectedTab = 0
                    }
                } else {
                    message = "Failed with status code: \(httpResponse.statusCode)"
                    showAlert = true
                }
            }
        } catch {
            message = "Request failed: \(error.localizedDescription)"
            showAlert = true
        }
    }
}
