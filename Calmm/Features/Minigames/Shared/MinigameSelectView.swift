import SwiftUI
import SwiftData

struct MinigameSelectView: View {
    @Query private var cats: [CatModel]
    @State private var showingWhackAMouse = false

    private var cat: CatModel? { cats.first }

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE").ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("Mini Games")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                    .padding(.top, 60)
                    .padding(.bottom, 32)

                // Game cards
                VStack(spacing: 16) {
                    GameCard(
                        emoji: "🐭",
                        title: "Whack-a-Mouse",
                        description: "Tap the mice before they escape!",
                        coins: "coins per hit",
                        difficulty: "Easy",
                        difficultyColor: Color(hex: "5DCAA5"),
                        onTap: { showingWhackAMouse = true }
                    )

                    GameCard(
                        emoji: "🔒",
                        title: "More coming soon",
                        description: "Level up to unlock more games",
                        coins: "",
                        difficulty: "Locked",
                        difficultyColor: Color(hex: "A08070"),
                        onTap: {}
                    )
                    .opacity(0.5)
                    .disabled(true)
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
    let emoji: String
    let title: String
    let description: String
    let coins: String
    let difficulty: String
    let difficultyColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 40))
                    .frame(width: 64, height: 64)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(hex: "3D2C24"))

                    Text(description)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "A08070"))

                    HStack(spacing: 8) {
                        Text(difficulty)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(difficultyColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(difficultyColor.opacity(0.12))
                            )

                        if !coins.isEmpty {
                            Text("🪙 \(coins)")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(hex: "A08070"))
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "D0C0B8"))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "E0D5CC"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MinigameSelectView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
