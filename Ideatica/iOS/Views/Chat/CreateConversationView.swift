import SwiftUI

struct CreateConversationView: View {
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var foundUser: ChatUserResponse?
    @State private var searchTask: Task<Void, Never>?
    @State private var showSuccess = false
    
    @FocusState private var isUsernameFocused: Bool
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    
    let token: String
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Search username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .disableAutocorrection(true)
                .onChange(of: username) { _, newValue in
                    let lowered = newValue.lowercased()
                    if lowered != newValue { username = lowered }
                    
                    searchTask?.cancel()
                    foundUser = nil
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        guard lowered.count >= 3 else {
                            errorMessage = nil
                            return
                        }
                        await searchUser()
                    }
                }
            
            if isLoading {
                ProgressView()
            }
            
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(message == "User not found" ? .secondary : .red)
                    .padding()
            }
            
            if let user = foundUser {
                List {
                    Button {
                        Task { await createConversation(with: user.id) }
                    } label: {
                        Text(user.username)
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 150)
            }
            
            Spacer()
        }
        .navigationTitle("Create Conversation")
        .alert("Conversation created", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your new conversation is ready.")
        }
    }
    
    private func searchUser() async {
        guard username.count >= 3 else {
            errorMessage = nil
            foundUser = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        foundUser = nil
        
        guard let url = URL(string: "\(ApiConfig.baseURL)/public/user/username/\(username)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                return
            }
            
            if httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(ChatUserResponse.self, from: data)
                foundUser = decoded
            } else if httpResponse.statusCode == 404 {
                errorMessage = "User not found"
            } else {
                errorMessage = "Unexpected error: \(httpResponse.statusCode)"
            }
        } catch {
            if error is CancellationError { return }
            if (error as NSError).code == NSURLErrorCancelled { return }
            
            errorMessage = "Request failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func createConversation(with otherUserId: String) async {
        guard let myId = userStore.id else {
            errorMessage = "Missing current user id"
            return
        }
        
        let body: [String: Any] = [
            "participantIds": [myId, otherUserId]
        ]
        
        guard let url = URL(string: "\(ApiConfig.baseURLChat)/conversation/new"),
              let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "Invalid request"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response"
                return
            }
            
            switch httpResponse.statusCode {
            case 200, 201:
                showSuccess = true
            case 400...499:
                errorMessage = "Cannot create conversation (client error \(httpResponse.statusCode))"
            default:
                errorMessage = "Server error (\(httpResponse.statusCode))"
            }
        } catch {
            errorMessage = "Request failed: \(error.localizedDescription)"
        }
    }
}

struct ChatUserResponse: Codable {
    let id: String
    let username: String
    let name: String
}
