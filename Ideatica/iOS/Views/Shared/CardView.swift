//
//  CardView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct CardView: View {
    let title: String
    let topic: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(topic.uppercased())
                .font(.caption)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.orange)
                .cornerRadius(6)
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 10)
    }
}
