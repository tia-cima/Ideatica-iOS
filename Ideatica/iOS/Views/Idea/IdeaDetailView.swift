//
//  IdeaDetailView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct IdeaDetailView: View {
    let idea: Idea

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(idea.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(idea.topic.uppercased())
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.orange)
                    .cornerRadius(6)

                Text(formatDate(idea.insertDate))
                    .font(.caption)
                    .foregroundColor(.gray)

                Divider()

                Text(idea.content)
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Idea")
    }

    func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            let output = DateFormatter()
            output.dateStyle = .medium
            output.timeStyle = .short
            return output.string(from: date)
        }
        return iso
    }
}
