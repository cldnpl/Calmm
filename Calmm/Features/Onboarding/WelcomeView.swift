//
//  WelcomeView.swift
//  Calmm
//
//  Created by Raffaele Barra on 07/04/2026.
//


import SwiftUI

struct WelcomeView: View {
    let onFinished: () -> Void

    @State private var progress: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var catOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var barOpacity: Double = 0

    private let fillDuration: Double = 2.2

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App name
                Text("Purr")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .opacity(titleOpacity)

                Text("your virtual cat companion")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color(hex: "A08070"))
                    .padding(.top, 6)
                    .opacity(subtitleOpacity)

                Spacer()

                // Cat
                Image("TailUp")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(90))
                    .opacity(catOpacity)

                Spacer()

                // Progress bar
                VStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(hex: "E0D5CC"))
                                .frame(height: 6)

                            Capsule()
                                .fill(Color(hex: "F0997B"))
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("loading...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(hex: "C0A898"))
                }
                .padding(.horizontal, 48)
                .opacity(barOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startSequence()
        }
    }

    private func startSequence() {
        withAnimation(.easeIn(duration: 0.6)) {
            titleOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
            subtitleOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.7).delay(0.5)) {
            catOpacity = 1
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.8)) {
            barOpacity = 1
        }
        withAnimation(.easeInOut(duration: fillDuration).delay(0.9)) {
            progress = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9 + fillDuration + 0.2) {
            onFinished()
        }
    }
}

#Preview {
    WelcomeView(onFinished: {})
}
