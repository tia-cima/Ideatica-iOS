//
//  PrimaryButtonStyle.swift
//  Ideatica
//
//  Created by Mattia Cimadomo on 03/08/25.
//

import Foundation
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    private let padding: CGFloat = 8
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .padding(.init(
                top: padding,
                leading: padding * 6,
                bottom: padding,
                trailing: padding * 6
            ))
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 1.0))
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
