import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var cats: [CatModel]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("isSoundEnabled") private var isSoundEnabled = true
    @AppStorage("isNotificationsEnabled") private var isNotificationsEnabled = true

    @State private var showResetConfirmation = false
    @State private var showResetSuccess = false

    private var cat: CatModel? { cats.first }

    var body: some View {
        ZStack {
            Color(hex: "FDF6EE").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 60)
                        .padding(.bottom, 28)

                    statsSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                    achievementsSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                    settingsSection
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                }
            }
        }
        .confirmationDialog(
            "Reset game",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete all progress", role: .destructive) { resetGame() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete your cat and all progress. This cannot be undone.")
        }
        .alert("Game reset", isPresented: $showResetSuccess) {
            Button("OK") {}
        } message: {
            Text("All progress has been deleted. Restart the app to create a new cat.")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F0997B").opacity(0.12))
                    .frame(width: 104, height: 104)

                Image(cat?.furColor.assetName ?? "TailUp")
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 82, height: 82)
                    .rotationEffect(.degrees(90))
            }

            VStack(spacing: 4) {
                Text(cat?.name ?? "Calmm")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "F0997B"))
                    Text("Level \(cat?.level ?? 1)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(hex: "F0997B"))
                }
            }

            if let cat {
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(hex: "E0D5CC"))
                                .frame(height: 8)
                            Capsule()
                                .fill(Color(hex: "F0997B"))
                                .frame(
                                    width: geo.size.width * max(0, min(1, cat.xpProgress)),
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.6), value: cat.xpProgress)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(cat.xp) xp")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "A08070"))
                        Spacer()
                        Text("\(cat.xpForNextLevel) xp to level \(cat.level + 1)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "A08070"))
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Stats")

            HStack(spacing: 12) {
                statCard(
                    systemImage: "dollarsign.circle.fill",
                    imageColor: Color(hex: "EF9F27"),
                    value: "\(cat?.coins ?? 0)",
                    label: "coins"
                )
                statCard(
                    systemImage: "star.fill",
                    imageColor: Color(hex: "F0997B"),
                    value: "\(cat?.level ?? 1)",
                    label: "level"
                )
                statCard(
                    systemImage: "sparkles",
                    imageColor: Color(hex: "5DCAA5"),
                    value: "\(cat?.xp ?? 0)",
                    label: "total xp"
                )
            }

            HStack(spacing: 12) {
                statCard(
                    systemImage: "fork.knife",
                    imageColor: Color(hex: "F0997B"),
                    value: "\(Int(cat?.hunger ?? 0))%",
                    label: "hunger"
                )
                statCard(
                    systemImage: "heart.fill",
                    imageColor: Color(hex: "ED93B1"),
                    value: "\(Int(cat?.happiness ?? 0))%",
                    label: "happiness"
                )
                statCard(
                    systemImage: "shower.fill",
                    imageColor: Color(hex: "85B7EB"),
                    value: "\(Int(cat?.cleanliness ?? 0))%",
                    label: "clean"
                )
            }
        }
    }

    private func statCard(systemImage: String, imageColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(imageColor)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "3D2C24"))
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "A08070"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "E0D5CC"), lineWidth: 1))
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Achievements")

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 4),
                spacing: 12
            ) {
                ForEach(achievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
    }

    private var achievements: [Achievement] {
        [
            Achievement(
                id: "first_pet",
                systemImage: "hand.draw.fill",
                imageColor: Color(hex: "F0997B"),
                title: "First pet",
                isUnlocked: (cat?.happiness ?? 0) > 0
            ),
            Achievement(
                id: "coin_hoarder",
                systemImage: "dollarsign.circle.fill",
                imageColor: Color(hex: "EF9F27"),
                title: "Hoarder",
                isUnlocked: (cat?.coins ?? 0) >= 500
            ),
            Achievement(
                id: "level_up",
                systemImage: "star.fill",
                imageColor: Color(hex: "F0997B"),
                title: "Level 5",
                isUnlocked: (cat?.level ?? 1) >= 5
            ),
            Achievement(
                id: "well_fed",
                systemImage: "fork.knife",
                imageColor: Color(hex: "5DCAA5"),
                title: "Well fed",
                isUnlocked: (cat?.hunger ?? 0) >= 80
            ),
            Achievement(
                id: "squeaky_clean",
                systemImage: "shower.fill",
                imageColor: Color(hex: "85B7EB"),
                title: "Squeaky clean",
                isUnlocked: (cat?.cleanliness ?? 0) >= 90
            ),
            Achievement(
                id: "game_player",
                systemImage: "gamecontroller.fill",
                imageColor: Color(hex: "AFA9EC"),
                title: "Gamer",
                isUnlocked: (cat?.xp ?? 0) >= 30
            ),
            Achievement(
                id: "rich_cat",
                systemImage: "banknote.fill",
                imageColor: Color(hex: "EF9F27"),
                title: "Rich cat",
                isUnlocked: (cat?.coins ?? 0) >= 1000
            ),
            Achievement(
                id: "loyal_owner",
                systemImage: "crown.fill",
                imageColor: Color(hex: "F0997B"),
                title: "Level 10",
                isUnlocked: (cat?.level ?? 1) >= 10
            )
        ]
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Settings")

            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        settingsIcon("speaker.wave.2.fill", color: Color(hex: "5DCAA5"))
                        Text("Sound")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "3D2C24"))
                        Spacer()
                        Toggle("", isOn: $isSoundEnabled)
                            .tint(Color(hex: "F0997B"))
                            .labelsHidden()
                    }
                }

                settingsDivider

                settingsRow {
                    HStack {
                        settingsIcon("bell.fill", color: Color(hex: "F0997B"))
                        Text("Notifications")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "3D2C24"))
                        Spacer()
                        Toggle("", isOn: $isNotificationsEnabled)
                            .tint(Color(hex: "F0997B"))
                            .labelsHidden()
                    }
                }

                settingsDivider

                settingsRow {
                    Button(action: { showResetConfirmation = true }) {
                        HStack {
                            settingsIcon("arrow.counterclockwise", color: Color(hex: "E24B4A"))
                            Text("Reset game")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(hex: "E24B4A"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundStyle(Color(hex: "D0C0B8"))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "E0D5CC"), lineWidth: 1))
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(hex: "A08070"))
            .textCase(.uppercase)
            .tracking(0.8)
    }

    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }

    private func settingsIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 30, height: 30)
            .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)))
            .padding(.trailing, 8)
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(Color(hex: "E0D5CC"))
            .frame(height: 0.5)
            .padding(.leading, 54)
    }

    private func resetGame() {
        guard let cat else { return }
        modelContext.delete(cat)
        try? modelContext.save()
        showResetSuccess = true
    }
}

struct Achievement: Identifiable {
    let id: String
    let systemImage: String
    let imageColor: Color
    let title: String
    let isUnlocked: Bool
}

#Preview {
    ProfileView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
