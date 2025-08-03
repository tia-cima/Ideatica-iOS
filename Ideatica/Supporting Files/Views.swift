//
//  Views.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

struct HeroView: View {
    var body: some View {
    #if os(iOS)
        VStack(alignment: .leading, spacing: 12) {
            Image("Bulb")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
                .padding(.top, 32)

            Text("Ideatica")
                .font(.custom("SpaceGrotesk-Medium", size: 64))
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color("Orange"), Color("Pink")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Where ideas meet.")
                .font(.custom("SpaceGrotesk-Regular", size: 20))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 24)
    #else
        Text("Ideatica, where ideas meet.")
            .font(.title)
    #endif
    }
}

struct ProfileHeader: View {
    @State var picture: String

    private let size: CGFloat = 100

    var body: some View {
    #if os(iOS)
        AsyncImage(url: URL(string: picture), content: { image in
            image.resizable()
        }, placeholder: {
            Color.clear
        })
        .frame(width: self.size, height: self.size)
        .clipShape(Circle())
        .padding(.bottom, 24)
    #else
        Text("Profile")
    #endif
    }
}

struct ProfileCell: View {
    @State var key: String
    @State var value: String

    private let size: CGFloat = 14

    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: self.size, weight: .semibold))
            Spacer()
            Text(value)
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

struct PrimaryButtonStyle: ButtonStyle {
    private let padding: CGFloat = 8

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .padding(.init(top: self.padding,
                           leading: self.padding * 6,
                           bottom: self.padding,
                           trailing: self.padding * 6))
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
