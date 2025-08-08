//
//  ProfileView.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileHeader(picture: userStore.picture)
                .padding(.bottom, 8)

            Group {
                ProfileCell(key: "Username", value: userStore.username)
                ProfileCell(key: "Name", value: userStore.name)
                ProfileCell(key: "Email", value: userStore.email)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}
