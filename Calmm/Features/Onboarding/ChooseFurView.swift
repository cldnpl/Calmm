//
//  ChooseFurView.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import SwiftUI

struct ChooseFurView: View {
    let cat: CatModel
    let onNext: () -> Void

    @State private var selectedFur: FurColor = .orange

    var body: some View {
        VStack(spacing: 28) {

            // Title
            VStack(spacing: 8) {
                Text("Choose your cat")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(hex: "3D2C24"))

                Text("You can always change this later")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "A08070"))
            }

            // Cat preview
            Image(selectedFur.assetName)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(90))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedFur)

            // Fur color options
            HStack(spacing: 20) {
                ForEach(FurColor.allCases, id: \.self) { fur in
                    FurOptionButton(
                        fur: fur,
                        isSelected: selectedFur == fur,
                        onTap: { selectedFur = fur }
                    )
                }
            }

            // Next button
            OnboardingNextButton(title: "Next") {
                cat.furColor = selectedFur
                onNext()
            }
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Subviews

private struct FurOptionButton: View {
    let fur: FurColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(fur.assetName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(90))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? Color(hex: "F0997B").opacity(0.15) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color(hex: "F0997B") : Color(hex: "E0D5CC"),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                Text(fur.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? Color(hex: "D85A30") : Color(hex: "A08070"))
            }
        }
        .buttonStyle(.plain)
    }
}
