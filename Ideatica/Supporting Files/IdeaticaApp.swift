//
//  IdeaticaApp.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import SwiftUI

@main
struct IdeaticaApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
            #if os(iOS)
                .padding(.bottom, 16)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .background(Color("Background").ignoresSafeArea())
                .buttonStyle(PrimaryButtonStyle())
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    UITableView.appearance().bounces = false
                }
            #else
                .padding(.bottom, 32)
                .frame(maxWidth: 400, maxHeight: 300)
            #endif
        }
    }
}
