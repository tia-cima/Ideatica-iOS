//
//  WebsocketManager.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 09/08/25.
//

import Foundation

enum WSMessageType: String, Codable {
    case SUBSCRIBE
    case SEND
}

struct OutgoingWSMessage: Codable {
    let type: WSMessageType
    let conversationId: String
    let from: String?
    let to: String?
    let content: String?
}

struct IncomingKafkaMessage: Codable {
    let to: String
    let from: String
    let content: String
    let timestamp: String
}

@MainActor
final class ChatWebSocket: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published private(set) var isConnected = false

    private var task: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private var wsURL: URL
    private var conversationId: String = ""

    init(wsURL: URL) {
        self.wsURL = wsURL
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }

    func connect(conversationId: String) {
        self.conversationId = conversationId
        let request = URLRequest(url: wsURL)
        task = urlSession.webSocketTask(with: request)
        task?.resume()
        receiveLoop()
        // We'll send SUBSCRIBE in urlSession(_:didOpenWithProtocol:) once connected
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }

    func subscribe() {
        let msg = OutgoingWSMessage(type: .SUBSCRIBE,
                                    conversationId: conversationId,
                                    from: nil, to: nil, content: nil)
        send(msg)
    }

    func sendMessage(conversationId: String, from: String, to: String, content: String) {
        let msg = OutgoingWSMessage(type: .SEND,
                                    conversationId: conversationId,
                                    from: from, to: to, content: content)
        send(msg)
    }

    private func send(_ encodable: Encodable) {
        guard let task else { return }
        do {
            let data = try JSONEncoder().encode(AnyEncodable(encodable))
            if let text = String(data: data, encoding: .utf8) {
                task.send(.string(text)) { error in
                    if let error = error { print("WS send error:", error) }
                }
            }
        } catch {
            print("WS encode error:", error)
        }
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("WS receive error:", error)
            case .success(let message):
                switch message {
                case .string(let text):
                    NotificationCenter.default.post(
                        name: .didReceiveChatMessage,
                        object: nil,
                        userInfo: ["payload": text]
                    )
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        NotificationCenter.default.post(
                            name: .didReceiveChatMessage,
                            object: nil,
                            userInfo: ["payload": text]
                        )
                    }
                @unknown default:
                    break
                }
                // keep listening
                self.receiveLoop()
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        isConnected = true
        // send SUBSCRIBE as soon as the socket is open
        subscribe()
        // optional: start pings
        ping()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
    }

    private func ping() {
        task?.sendPing { [weak self] error in
            if let error = error {
                print("WS ping error:", error)
                return
            }
            // ping again in 30s
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
                self?.ping()
            }
        }
    }
}

/// Helper to encode `Encodable` erasure
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ encodable: Encodable) {
        _encode = encodable.encode
    }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

extension Notification.Name {
    static let didReceiveChatMessage = Notification.Name("didReceiveChatMessage")
}
