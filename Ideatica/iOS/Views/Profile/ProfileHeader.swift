//
//  ProfileHeader.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct ProfileHeader: View {
    var picture: String?

    private let size: CGFloat = 100

    var body: some View {
    #if os(iOS)
        HStack {
            Spacer()
            if let picture, let url = URL(string: picture) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: size, height: size)
            }
            Spacer()
        }
        .padding(.bottom, 24)
    #else
        Text("Profile")
    #endif
    }
}
