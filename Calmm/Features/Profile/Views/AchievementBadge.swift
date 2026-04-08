//
//  AchievementBadge.swift
//  Calmm
//
//  Created by Raffaele Barra on 08/04/2026.
//


import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.imageColor.opacity(0.12)
                          : Color(hex: "F1EFE8"))
                    .frame(width: 56, height: 56)

                if achievement.isUnlocked {
                    Image(systemName: achievement.systemImage)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(achievement.imageColor)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color(hex: "D3D1C7"))
                }
            }

            Text(achievement.isUnlocked ? achievement.title : "???")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(achievement.isUnlocked
                                 ? Color(hex: "3D2C24")
                                 : Color(hex: "B4B2A9"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)
        }
    }
}
