//
//  HeroView.swift
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
