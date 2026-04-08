//
//  NameYourCatView.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import SwiftUI

struct NameYourCatView: View {
    let cat: CatModel
    let onDone: () -> Void

    @State private var catName: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private var canProceed: Bool {
        !catName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 32) {

            // Title
            VStack(spacing: 8) {
                Text("Name your cat")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(hex: "3D2C24"))

                Text("What will you call them?")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(hex: "A08070"))
            }

            // Cat preview
            Image(cat.furColor.assetName)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(90))

            // Name input
            VStack(spacing: 8) {
                TextField("e.g. Mochi, Luna, Pixel...", text: $catName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isTextFieldFocused ? Color(hex: "F0997B") : Color(hex: "E0D5CC"),
                                lineWidth: isTextFieldFocused ? 2 : 1
                            )
                    )
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if canProceed { saveName() }
                    }
                    .onChange(of: catName) { _, newValue in
                        // Cap name at 12 characters
                        if newValue.count > 12 {
                            catName = String(newValue.prefix(12))
                        }
                    }

                if catName.count >= 10 {
                    Text("\(catName.count)/12")
                        .font(.system(size: 11))
                        .foregroundStyle(catName.count == 12 ? Color(hex: "D85A30") : Color(hex: "A08070"))
                }
            }

            // Done button
            OnboardingNextButton(
                title: "Let's go!",
                disabled: !canProceed
            ) {
                saveName()
            }
        }
        .padding(.horizontal, 32)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func saveName() {
        cat.name = catName.trimmingCharacters(in: .whitespaces)
        onDone()
    }
}