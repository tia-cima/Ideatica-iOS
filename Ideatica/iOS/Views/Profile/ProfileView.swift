//
//  ProfileView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct ProfileView: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileHeader(picture: user.picture)
                .padding(.bottom, 8)

            Group {
                ProfileCell(key: "ID", value: user.id)
                ProfileCell(key: "Name", value: user.name)
                ProfileCell(key: "Email", value: user.email)
                ProfileCell(key: "Email verified?", value: user.emailVerified)
                ProfileCell(key: "Updated at", value: user.updatedAt)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}
