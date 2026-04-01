//
//  ChooseEyeColorView.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import SwiftUI

struct ChooseEyeColorView: View {
    let cat: CatModel
    let onNext: () -> Void

    @State private var selectedHex: String = EyeColor.green.rawValue
    @State private var customColor: Color = Color(hex: EyeColor.green.rawValue)
    @State private var isCustomSelected: Bool = false

    var body: some View {
        VStack(spacing: 32) {

            // Title
            VStack(spacing: 8) {
                Text("Choose eye color")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(hex: "3D2C24"))

                Text("Pick a preset or go full custom")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "A08070"))
            }

            // Cat preview with eye color tint indicator
            ZStack {
                Image(cat.furColor.assetName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(90))

                // Eye color preview badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color(hex: selectedHex))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                }
                .frame(width: 180, height: 180)
            }

            // Preset color circles
            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    ForEach(EyeColor.allCases, id: \.self) { preset in
                        EyePresetButton(
                            hex: preset.rawValue,
                            label: preset.displayName,
                            isSelected: !isCustomSelected && selectedHex == preset.rawValue,
                            onTap: {
                                isCustomSelected = false
                                selectedHex = preset.rawValue
                                customColor = Color(hex: preset.rawValue)
                            }
                        )
                    }
                }

                // Custom color picker row
                Button {
                    isCustomSelected = true
                    selectedHex = customColor.hexString
                } label: {
                    HStack(spacing: 12) {
                        // Color wheel icon
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [.red, .yellow, .green, .blue, .purple, .red],
                                        center: .center
                                    )
                                )
                                .frame(width: 32, height: 32)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 14, height: 14)
                        }

                        Text("Custom color")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(hex: "3D2C24"))

                        Spacer()

                        if isCustomSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: "F0997B"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isCustomSelected ? Color(hex: "F0997B").opacity(0.1) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isCustomSelected ? Color(hex: "F0997B") : Color(hex: "E0D5CC"),
                                lineWidth: isCustomSelected ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)

                // Show the actual ColorPicker only when custom is selected
                if isCustomSelected {
                    ColorPicker("Pick your color", selection: $customColor, supportsOpacity: false)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "E0D5CC"), lineWidth: 1)
                        )
                        .onChange(of: customColor) { _, newColor in
                            selectedHex = newColor.hexString
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Next button
            OnboardingNextButton(title: "Next") {
                cat.eyeColor = selectedHex
                onNext()
            }
        }
        .padding(.horizontal, 32)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isCustomSelected)
    }
}

// MARK: - Subviews

private struct EyePresetButton: View {
    let hex: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color(hex: "F0997B") : Color.clear,
                                lineWidth: 3
                            )
                            .padding(-4)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? Color(hex: "D85A30") : Color(hex: "A08070"))
            }
        }
        .buttonStyle(.plain)
    }
}