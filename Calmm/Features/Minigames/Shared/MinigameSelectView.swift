import SwiftUI
import SwiftData

struct MinigameSelectView: View {
    @State private var showingWhackAMouse = false

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE").ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Mini Games")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                VStack(spacing: 16) {
                    GameCard(
                        icon: "computermouse.fill",
                        iconColor: Color(hex: "5DCAA5"),
                        title: "Whack-a-Mouse",
                        description: "Tap the mice before they escape!",
                        rewardLabel: "coins per hit",
                        difficulty: "Easy",
                        difficultyColor: Color(hex: "5DCAA5"),
                        isLocked: false,
                        onTap: { showingWhackAMouse = true }
                    )

                    GameCard(
                        icon: "lock.fill",
                        iconColor: Color(hex: "B4B2A9"),
                        title: "More coming soon",
                        description: "Level up to unlock more games",
                        rewardLabel: "",
                        difficulty: "Locked",
                        difficultyColor: Color(hex: "B4B2A9"),
                        isLocked: true,
                        onTap: {}
                    )
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showingWhackAMouse) {
            WhackAMouseView()
        }
    }
}

private struct GameCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let rewardLabel: String
    let difficulty: String
    let difficultyColor: Color
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isLocked ? Color(hex: "B4B2A9") : Color(hex: "3D2C24"))

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "A08070"))

                    HStack(spacing: 8) {
                        Text(difficulty)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(difficultyColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(difficultyColor.opacity(0.12)))

                        if !rewardLabel.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "EF9F27"))
                                Text(rewardLabel)
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(hex: "A08070"))
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(hex: "D0C0B8"))
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "E0D5CC"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.55 : 1)
        .disabled(isLocked)
    }
}

#Preview {
    MinigameSelectView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
