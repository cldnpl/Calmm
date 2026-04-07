//
//  WhackAMouseView.swift
//  Calmm
//
//  Created by Raffaele Barra on 07/04/2026.
//


import SwiftUI
import SpriteKit
import SwiftData

enum TutorialStep {
    case step1_showMouse
    case step1_waitingTap
    case step2_missDemo
    case step2_waited
    case step3_ready
    case done
}

struct WhackAMouseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [CatModel]

    @AppStorage("hasPlayedWhackAMouse") private var hasPlayedBefore = false

    @State private var phase: Phase = .start
    @State private var lives = 3
    @State private var score = 0
    @State private var finalCoins = 0
    @State private var finalXP = 0
    @State private var showPauseMenu = false
    @State private var showCatCameo = false
    @State private var cameoMessage = ""
    @State private var gameScene: WhackAMouseScene?
    @State private var bridge: GameBridge?
    @State private var tutorialStep: TutorialStep = .step1_showMouse
    @State private var showTutorial = false

    private var cat: CatModel? { cats.first }
    private let maxLives = 3

    enum Phase { case start, playing, result }

    var body: some View {
        ZStack {
            switch phase {
            case .start:
                startScreen.transition(.opacity)
            case .playing:
                gameScreen.transition(.opacity)
            case .result:
                WhackAMouseResultView(
                    score: score,
                    coins: finalCoins,
                    xp: finalXP,
                    onPlayAgain: restartGame,
                    onDone: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: phase)
    }

    // MARK: - Start screen

    private var startScreen: some View {
        ZStack {
            Color(hex: "FDF6EE").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: "A08070"))
                            .padding(10)
                            .background(Circle().fill(Color(hex: "E0D5CC").opacity(0.6)))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 56)
                    .padding(.trailing, 24)
                }
                Spacer()
                Text("🐭").font(.system(size: 80))
                VStack(spacing: 10) {
                    Text("Whack-a-Mouse!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "3D2C24"))
                    Text("Tap mice before they escape.\nMiss 3 and it's game over!")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "A08070"))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                HStack(spacing: 6) {
                    ForEach(0..<maxLives, id: \.self) { _ in
                        Text("🐾").font(.system(size: 24))
                    }
                }
                .padding(.top, 24)
                VStack(spacing: 8) {
                    tipRow(icon: "🔥", text: "Hit 3 in a row for a combo bonus")
                    tipRow(icon: "⚡️", text: "Mice get faster as your score grows")
                    tipRow(icon: "🐾", text: "Miss 3 mice and it's game over")
                }
                .padding(.top, 28)
                .padding(.horizontal, 40)
                Spacer()
                Button(action: startGame) {
                    Text(!hasPlayedBefore ? "Start tutorial" : "Play!")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(hex: "F0997B")))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 40)
                .padding(.bottom, 52)
            }
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Text(icon).font(.system(size: 18))
            Text(text).font(.system(size: 14)).foregroundStyle(Color(hex: "A08070"))
            Spacer()
        }
    }

    // MARK: - Game screen

    private var gameScreen: some View {
        ZStack(alignment: .top) {

            // SpriteKit — fullscreen, receives ALL touches
            if let gameScene {
                SpriteView(scene: gameScene)
                    .ignoresSafeArea()
            }

            // SwiftUI HUD — allowsHitTesting(false) so touches pass through to SpriteKit
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    // Lives
                    HStack(spacing: 4) {
                        ForEach(0..<maxLives, id: \.self) { i in
                            Text(i < lives ? "🐾" : "🩶")
                                .font(.system(size: 26))
                                .scaleEffect(i < lives ? 1.0 : 0.8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: lives)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.25)))

                    Spacer()

                    // Score
                    Text(String(format: "%06d", score))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                    Spacer()

                    // Pause — this DOES need hit testing
                    Button(action: pauseGame) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.25)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 56)
                .padding(.horizontal, 20)
                .allowsHitTesting(true) // HUD row keeps hit testing for pause button

                // Cat cameo area — no hit testing needed
                ZStack {
                    if showCatCameo {
                        HStack(alignment: .bottom, spacing: 8) {
                            Image(cat?.furColor.assetName ?? "TailUp")
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .rotationEffect(.degrees(90))

                            Text(cameoMessage)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(hex: "3D2C24"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.95))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Color(hex: "F0997B").opacity(0.5), lineWidth: 1)
                                        )
                                )
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(height: 90)
                .allowsHitTesting(false) // cat cameo passes touches through
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCatCameo)

                Spacer()
            }

            // Tutorial text overlay — purely visual, passes ALL touches to SpriteKit
            if showTutorial {
                tutorialOverlay
                    .allowsHitTesting(false) // ← KEY FIX: touches go through to SpriteKit
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: tutorialStep)
            }

            // Pause menu — this DOES block touches (it's a modal)
            if showPauseMenu {
                pauseMenuOverlay
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: showPauseMenu)
            }

            // Tutorial action cards — shown on top of everything, DO need hit testing
            if showTutorial && tutorialNeedsCard {
                tutorialCardOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: tutorialStep)
            }
        }
    }

    // MARK: - Tutorial

    private var tutorialNeedsCard: Bool {
        tutorialStep == .step2_waited || tutorialStep == .step3_ready
    }

    // Pure visual overlay — no buttons, passes touches through
    @ViewBuilder
    private var tutorialOverlay: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            switch tutorialStep {
            case .step1_showMouse, .step1_waitingTap:
                VStack(spacing: 12) {
                    Spacer()
                    PulsingArrow()
                    Text("Tap the mouse! 👆")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.35)
                }

            case .step2_missDemo:
                VStack {
                    Spacer()
                    Text("Watch what happens\nif you miss... 👀")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 4)
                        .padding(.bottom, UIScreen.main.bounds.height * 0.3)
                    Spacer()
                }

            default:
                EmptyView()
            }
        }
    }

    // Cards with buttons — separate layer that CAN be tapped
    @ViewBuilder
    private var tutorialCardOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            switch tutorialStep {
            case .step2_waited:
                tutorialCard(
                    emoji: "🐾",
                    title: "You lost a life!",
                    body: "Every mouse that escapes costs you a paw. Lose all 3 and it's game over!",
                    buttonLabel: "Got it!",
                    action: advanceTutorial
                )
            case .step3_ready:
                tutorialCard(
                    emoji: "⚡️",
                    title: "Speed matters!",
                    body: "As your score grows the mice appear faster and faster. Stay sharp!",
                    buttonLabel: "Let's go! 🐭",
                    action: finishTutorial
                )
            default:
                EmptyView()
            }
        }
    }

    private func tutorialCard(emoji: String, title: String, body: String, buttonLabel: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 20) {
            Text(emoji).font(.system(size: 52))
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "3D2C24"))
            Text(body)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: "A08070"))
                .multilineTextAlignment(.center)
            Button(action: action) {
                Text(buttonLabel)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "F0997B")))
            }
            .buttonStyle(.plain)
        }
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color(hex: "FDF6EE")))
        .padding(.horizontal, 32)
    }

    // MARK: - Pause menu

    private var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "3D2C24"))
                Text(String(format: "%06d", score))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "F0997B"))
                HStack(spacing: 6) {
                    ForEach(0..<maxLives, id: \.self) { i in
                        Text(i < lives ? "🐾" : "🩶").font(.system(size: 24))
                    }
                }
                VStack(spacing: 12) {
                    Button(action: resumeGame) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "F0997B")))
                    }
                    .buttonStyle(.plain)
                    Button(action: giveUp) {
                        Text("Give up")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color(hex: "A08070"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "E0D5CC"), lineWidth: 1))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
            }
            .padding(32)
            .background(RoundedRectangle(cornerRadius: 28).fill(Color(hex: "FDF6EE")))
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Tutorial flow

    private func advanceTutorial() {
        switch tutorialStep {
        case .step2_waited:
            withAnimation { tutorialStep = .step3_ready }
        default:
            break
        }
    }

    private func finishTutorial() {
        hasPlayedBefore = true
        withAnimation {
            showTutorial = false
            tutorialStep = .done
        }
        gameScene?.startGame()
    }

    // MARK: - Game actions

    private func startGame() {
        lives = maxLives
        score = 0

        let b = GameBridge(
            onLivesChange: { l in lives = l },
            onScoreChange: { s in score = s },
            onGameOver: { _, coins, xp in
                finalCoins = coins
                finalXP = xp
                applyRewards(coins: coins, xp: xp)
                withAnimation { phase = .result }
            },
            onCombo: { combo in triggerCatCameo(combo: combo) },
            onTutorialMouseAppeared: {
                withAnimation { tutorialStep = .step1_waitingTap }
            },
            onTutorialMouseMissed: {
                withAnimation { tutorialStep = .step2_waited }
            },
            onTutorialTapSucceeded: {
                // Player tapped the tutorial mouse — move to miss demo
                withAnimation { tutorialStep = .step2_missDemo }
                gameScene?.startTutorialStep2()
            }
        )
        bridge = b

        let scene = WhackAMouseScene()
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .aspectFill
        scene.gameDelegate = b
        gameScene = scene

        withAnimation { phase = .playing }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if !hasPlayedBefore {
                tutorialStep = .step1_showMouse
                showTutorial = true
                gameScene?.startTutorialStep1()
            } else {
                gameScene?.startGame()
            }
        }
    }

    private func pauseGame() {
        gameScene?.pauseGame()
        withAnimation { showPauseMenu = true }
    }

    private func resumeGame() {
        withAnimation { showPauseMenu = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            gameScene?.resumeGame()
        }
    }

    private func giveUp() {
        gameScene?.quitWithoutReward()
        withAnimation { showPauseMenu = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
    }

    private func restartGame() {
        gameScene?.quitWithoutReward()
        gameScene = nil
        bridge = nil
        showCatCameo = false
        showPauseMenu = false
        showTutorial = false
        phase = .start
    }

    private func triggerCatCameo(combo: Int) {
        guard !showCatCameo else { return }
        let messages = [
            "You're on fire! 🔥", "Keep going! 😻",
            "\(combo)x combo!! 🎉", "Amazing! ⭐️", "Go go go! 🐾"
        ]
        cameoMessage = messages.randomElement() ?? "Meow! 🐱"
        withAnimation { showCatCameo = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showCatCameo = false }
        }
    }

    private func applyRewards(coins: Int, xp: Int) {
        guard let cat else { return }
        cat.coins += coins
        cat.xp += xp
        cat.recalculateLevel()
        try? modelContext.save()
    }
}

// MARK: - Pulsing arrow

struct PulsingArrow: View {
    @State private var bounce = false
    var body: some View {
        Image(systemName: "arrow.down")
            .font(.system(size: 44, weight: .bold))
            .foregroundStyle(Color(hex: "F0997B"))
            .shadow(color: .black.opacity(0.4), radius: 4)
            .offset(y: bounce ? 10 : 0)
            .animation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true), value: bounce)
            .onAppear { bounce = true }
    }
}

// MARK: - GameBridge

final class GameBridge: WhackAMouseSceneDelegate {
    private let onLivesChange: (Int) -> Void
    private let onScoreChange: (Int) -> Void
    private let onGameOver: (Int, Int, Int) -> Void
    private let onCombo: (Int) -> Void
    private let onTutorialMouseAppeared: () -> Void
    private let onTutorialMouseMissed: () -> Void
    private let onTutorialTapSucceeded: () -> Void

    init(
        onLivesChange: @escaping (Int) -> Void,
        onScoreChange: @escaping (Int) -> Void,
        onGameOver: @escaping (Int, Int, Int) -> Void,
        onCombo: @escaping (Int) -> Void,
        onTutorialMouseAppeared: @escaping () -> Void,
        onTutorialMouseMissed: @escaping () -> Void,
        onTutorialTapSucceeded: @escaping () -> Void
    ) {
        self.onLivesChange = onLivesChange
        self.onScoreChange = onScoreChange
        self.onGameOver = onGameOver
        self.onCombo = onCombo
        self.onTutorialMouseAppeared = onTutorialMouseAppeared
        self.onTutorialMouseMissed = onTutorialMouseMissed
        self.onTutorialTapSucceeded = onTutorialTapSucceeded
    }

    func livesChanged(lives: Int) { DispatchQueue.main.async { self.onLivesChange(lives) } }
    func scoreChanged(score: Int) { DispatchQueue.main.async { self.onScoreChange(score) } }
    func gameOver(score: Int, coins: Int, xp: Int) { DispatchQueue.main.async { self.onGameOver(score, coins, xp) } }
    func comboReached(combo: Int) { DispatchQueue.main.async { self.onCombo(combo) } }
    func tutorialMouseAppeared() { DispatchQueue.main.async { self.onTutorialMouseAppeared() } }
    func tutorialMouseMissed() { DispatchQueue.main.async { self.onTutorialMouseMissed() } }
    func tutorialTapSucceeded() { DispatchQueue.main.async { self.onTutorialTapSucceeded() } }
}

#Preview {
    WhackAMouseView()
        .modelContainer(for: CatModel.self, inMemory: true)
}
