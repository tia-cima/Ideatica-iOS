//
//  ProfileCell.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct ProfileCell: View {
    var key: String?
    var value: String?

    private let size: CGFloat = 14

    var body: some View {
        HStack {
            Text(key ?? "-")
                .font(.system(size: self.size, weight: .semibold))
            Spacer()
            Text(value ?? "-")
                .font(.system(size: self.size, weight: .regular))
            #if os(iOS)
                .foregroundColor(Color("Grey"))
            #endif
        }
    #if os(iOS)
        .listRowBackground(Color.white)
    #endif
    }
}

