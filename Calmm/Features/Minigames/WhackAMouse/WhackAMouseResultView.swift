//
//  WhackAMouseResultView.swift
//  Calmm
//
//  Created by Raffaele Barra on 07/04/2026.
//


import SwiftUI

struct WhackAMouseResultView: View {
    let score: Int
    let coins: Int
    let xp: Int
    let onPlayAgain: () -> Void
    let onDone: () -> Void

    @State private var coinsAnimated = 0
    @State private var xpAnimated = 0
    @State private var appeared = false
    @State private var inputEnabled = false

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text(score >= 5000 ? "🏆" : score >= 2000 ? "⭐️" : "🐭")
                    .font(.system(size: 80))
                    .scaleEffect(appeared ? 1 : 0.3)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appeared)

                Text(resultTitle)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .padding(.top, 16)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.3), value: appeared)

                Text(String(format: "%06d", score))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "F0997B"))
                    .padding(.top, 10)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.4), value: appeared)

                Spacer()

                VStack(spacing: 12) {
                    Text("Rewards")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "A08070"))

                    HStack(spacing: 24) {
                        rewardCard(icon: "🪙", value: "+\(coinsAnimated)", label: "coins")
                        rewardCard(icon: "⭐️", value: "+\(xpAnimated)", label: "xp")
                    }
                }
                .padding(.horizontal, 40)
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.55), value: appeared)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        Text("Play again")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(hex: inputEnabled ? "F0997B" : "E0D5CC"))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!inputEnabled)

                    Button(action: onDone) {
                        Text("Done")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(hex: inputEnabled ? "A08070" : "D0C0B8"))
                    }
                    .buttonStyle(.plain)
                    .disabled(!inputEnabled)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 52)
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.7), value: appeared)
            }

            // "Get ready..." hint while buttons are locked
            if appeared && !inputEnabled {
                VStack {
                    Spacer()
                    Text("...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "C0A898"))
                        .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            appeared = true
            animateCounters()
            // Block buttons for 1.5 seconds so frantic taps don't skip the screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeIn(duration: 0.2)) {
                    inputEnabled = true
                }
            }
        }
    }

    private var resultTitle: String {
        if score >= 8000 { return "Legendary! 🔥" }
        if score >= 5000 { return "Amazing!" }
        if score >= 2000 { return "Good job!" }
        return "Keep trying!"
    }

    private func rewardCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(icon).font(.system(size: 32))
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "3D2C24"))
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "A08070"))
        }
        .frame(width: 110, height: 110)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "E0D5CC"), lineWidth: 1))
    }

    private func animateCounters() {
        let steps = 20
        let coinStep = max(1, coins / steps)
        let xpStep = max(1, xp / steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7 + Double(i) * 0.04) {
                coinsAnimated = min(coins, i * coinStep)
                xpAnimated = min(xp, i * xpStep)
            }
        }
    }
}

#Preview {
    WhackAMouseResultView(score: 3420, coins: 48, xp: 68, onPlayAgain: {}, onDone: {})
}
