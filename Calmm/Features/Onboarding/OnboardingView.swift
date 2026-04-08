//
//  OnboardingView.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import SwiftUI
import SwiftData

struct OnboardingView: View {
    let cat: CatModel

    @Environment(\.modelContext) private var modelContext
    @State private var currentStep = 1
    private let totalSteps = 2

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Step indicator dots
                HStack(spacing: 8) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step == currentStep ? Color(hex: "F0997B") : Color(hex: "E0D5CC"))
                            .frame(
                                width: step == currentStep ? 10 : 7,
                                height: step == currentStep ? 10 : 7
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentStep)
                    }
                }
                .padding(.top, 60)

                Spacer()

                Group {
                    switch currentStep {
                    case 1:
                        ChooseFurView(cat: cat, onNext: nextStep)
                    case 2:
                        NameYourCatView(cat: cat, onDone: finish)
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
    }

    private func nextStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep += 1
        }
    }

    private func finish() {
        cat.hasCompletedOnboarding = true
        try? modelContext.save()
    }
}

#Preview {
    OnboardingView(cat: CatModel())
        .modelContainer(for: CatModel.self, inMemory: true)
}
