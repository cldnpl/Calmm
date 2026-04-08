//
//  OnboardingNextButton.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import SwiftUI

struct OnboardingNextButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(disabled ? Color(hex: "E0D5CC") : Color(hex: "F0997B"))
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}