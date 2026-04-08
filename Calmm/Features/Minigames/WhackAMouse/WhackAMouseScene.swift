import SpriteKit
import SwiftUI

// MARK: - Delegate
protocol WhackAMouseSceneDelegate: AnyObject {
    func livesChanged(lives: Int)
    func scoreChanged(score: Int)
    func gameOver(score: Int, coins: Int, xp: Int)
    func comboReached(combo: Int)
    func tutorialMouseAppeared()
    func tutorialMouseMissed()
    func tutorialTapSucceeded()
}

extension WhackAMouseSceneDelegate {
    func tutorialMouseAppeared() {}
    func tutorialMouseMissed() {}
    func tutorialTapSucceeded() {}
}

final class WhackAMouseScene: SKScene {

    weak var gameDelegate: WhackAMouseSceneDelegate?

    // MARK: - Constants
    private let maxLives = 3
    private let holeSize: CGFloat = 52
    private let mouseSize: CGFloat = 90
    private let rows = 3
    private let cols = 3
    private let mouseDuration: Double = 1.5   // fixed for entire game

    // MARK: - Difficulty phases
    // Each phase lasts phaseDuration seconds.
    // spawnInterval and scoreTickAmount step up once per phase — never more often.
    private let phaseDuration: Double = 30

    private struct Phase {
        let spawnInterval: Double
        let scoreTickAmount: Int
        let scoreTickInterval: Double
        let doubleSpawn: Bool
    }

    private let phases: [Phase] = [
        Phase(spawnInterval: 1.50, scoreTickAmount: 1, scoreTickInterval: 0.10, doubleSpawn: false), // 0–30s
        Phase(spawnInterval: 1.20, scoreTickAmount: 2, scoreTickInterval: 0.09, doubleSpawn: false), // 30–60s
        Phase(spawnInterval: 1.00, scoreTickAmount: 3, scoreTickInterval: 0.08, doubleSpawn: false), // 60–90s
        Phase(spawnInterval: 0.80, scoreTickAmount: 4, scoreTickInterval: 0.07, doubleSpawn: false), // 90–120s
        Phase(spawnInterval: 0.65, scoreTickAmount: 5, scoreTickInterval: 0.06, doubleSpawn: true),  // 120–150s
        Phase(spawnInterval: 0.50, scoreTickAmount: 6, scoreTickInterval: 0.05, doubleSpawn: true),  // 150s+
    ]

    // MARK: - State
    private(set) var score: Int = 0
    private(set) var lives: Int = 3
    private var combo: Int = 0
    private var elapsedSeconds: Int = 0
    private var currentPhaseIndex: Int = 0
    private var isRunning = false
    private var isPaused2 = false
    private var isTutorialMode = false

    private var holes: [HoleNode] = []
    private var clockTimer: Timer?
    private var scoreTickTimer: Timer?
    private var spawnScheduler: DispatchWorkItem?

    // Current phase shorthand
    private var currentPhase: Phase { phases[min(currentPhaseIndex, phases.count - 1)] }

    // MARK: - Setup

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(Color(hex: "A8D8A8"))
        setupBackground()
        setupHoles()
    }

    override func willMove(from view: SKView) {
        stopEverything()
    }

    private func setupBackground() {
        let sky = SKSpriteNode(
            color: UIColor(Color(hex: "C8E6FA")),
            size: CGSize(width: size.width, height: size.height * 0.5)
        )
        sky.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        sky.zPosition = -2
        addChild(sky)

        let ground = SKSpriteNode(
            color: UIColor(Color(hex: "7BC67B")),
            size: CGSize(width: size.width, height: size.height * 0.5)
        )
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        ground.zPosition = -1
        addChild(ground)

        let dirt = SKSpriteNode(
            color: UIColor(Color(hex: "A0785A")),
            size: CGSize(width: size.width, height: 5)
        )
        dirt.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        dirt.zPosition = 0
        addChild(dirt)
    }

    private func setupHoles() {
        let marginX = size.width * 0.15
        let marginTopY = size.height * 0.42
        let spacingX = (size.width - marginX * 2) / CGFloat(cols - 1)
        let spacingY = size.height * 0.13

        for row in 0..<rows {
            for col in 0..<cols {
                let x = marginX + CGFloat(col) * spacingX
                let y = marginTopY - CGFloat(row) * spacingY
                let hole = HoleNode(
                    position: CGPoint(x: x, y: y),
                    holeSize: holeSize,
                    mouseSize: mouseSize
                )
                hole.onMissed = { [weak self] in
                    DispatchQueue.main.async { self?.handleMiss() }
                }
                holes.append(hole)
                addChild(hole)
            }
        }
    }

    // MARK: - Game control

    func startGame() {
        isTutorialMode = false
        isRunning = true
        isPaused2 = false
        score = 0
        lives = maxLives
        combo = 0
        elapsedSeconds = 0
        currentPhaseIndex = 0

        gameDelegate?.livesChanged(lives: lives)
        gameDelegate?.scoreChanged(score: score)

        startClockTimer()
        startScoreTicker()
        scheduleNextSpawn()
    }

    func startTutorialStep1() {
        isTutorialMode = true
        isRunning = false
        lives = maxLives
        score = 0
        gameDelegate?.livesChanged(lives: lives)
        gameDelegate?.scoreChanged(score: 0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self else { return }
            self.holes[4].showMouse(stayDuration: 99)
            self.gameDelegate?.tutorialMouseAppeared()
        }
    }

    func startTutorialStep2() {
        isTutorialMode = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            let hole = self.holes[1]
            hole.onMissed = { [weak self] in
                DispatchQueue.main.async {
                    self?.lives = max(0, (self?.lives ?? 1) - 1)
                    self?.gameDelegate?.livesChanged(lives: self?.lives ?? 2)
                    self?.gameDelegate?.tutorialMouseMissed()
                }
            }
            hole.showMouse(stayDuration: 2.2)
        }
    }

    func pauseGame() {
        guard isRunning, !isPaused2 else { return }
        isPaused2 = true
        stopTimers()
        holes.forEach { $0.freezeMouse() }
    }

    func resumeGame() {
        guard isRunning, isPaused2 else { return }
        isPaused2 = false
        startClockTimer()
        startScoreTicker()
        scheduleNextSpawn()
        holes.forEach { $0.unfreezeMouse() }
    }

    func quitWithoutReward() {
        stopEverything()
    }

    private func stopEverything() {
        isRunning = false
        isPaused2 = false
        isTutorialMode = false
        stopTimers()
        holes.forEach { $0.hideMouse(animated: false) }
    }

    private func stopTimers() {
        clockTimer?.invalidate()
        clockTimer = nil
        scoreTickTimer?.invalidate()
        scoreTickTimer = nil
        spawnScheduler?.cancel()
        spawnScheduler = nil
    }

    // MARK: - Clock (1 Hz)
    // Advances time. Checks if we crossed into a new phase.
    // This is the ONLY place difficulty changes — never on hit, never on score.

    private func startClockTimer() {
        clockTimer?.invalidate()
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, self.isRunning, !self.isPaused2 else { return }
            self.elapsedSeconds += 1

            let newPhaseIndex = min(
                self.phases.count - 1,
                Int(Double(self.elapsedSeconds) / self.phaseDuration)
            )

            // Only update if we actually moved to the next phase
            if newPhaseIndex != self.currentPhaseIndex {
                self.currentPhaseIndex = newPhaseIndex
                // Restart score ticker with new interval — only happens once per phase
                self.startScoreTicker()
                // Show phase change flash
                self.showPhaseChangeEffect()
            }
        }
    }

    // MARK: - Score ticker
    // Interval and amount come from currentPhase — set once per phase, never mid-phase

    private func startScoreTicker() {
        scoreTickTimer?.invalidate()
        scoreTickTimer = Timer.scheduledTimer(
            withTimeInterval: currentPhase.scoreTickInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self, self.isRunning, !self.isPaused2 else { return }
            self.score += self.currentPhase.scoreTickAmount
            self.gameDelegate?.scoreChanged(score: self.score)
        }
    }

    // MARK: - Spawn
    // Uses currentPhase.spawnInterval — stable within a phase, steps cleanly at phase boundary

    private func scheduleNextSpawn() {
        guard isRunning, !isPaused2 else { return }
        let interval = currentPhase.spawnInterval
        let jitter = Double.random(in: -0.06...0.06)  // tiny jitter so it doesn't feel robotic
        let delay = max(0.25, interval + jitter)

        let item = DispatchWorkItem { [weak self] in
            guard let self, self.isRunning, !self.isPaused2 else { return }
            self.spawnMouse()
            if self.currentPhase.doubleSpawn {
                let doubleDelay = Double.random(in: 0.15...0.30)
                DispatchQueue.main.asyncAfter(deadline: .now() + doubleDelay) { [weak self] in
                    guard let self, self.isRunning, !self.isPaused2 else { return }
                    self.spawnMouse()
                }
            }
            self.scheduleNextSpawn()
        }
        spawnScheduler = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    private func spawnMouse() {
        let available = holes.filter { !$0.isOccupied }
        guard let hole = available.randomElement() else { return }
        hole.showMouse(stayDuration: mouseDuration)
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isTutorialMode {
            for hole in holes where hole.isOccupied {
                if hole.containsTouch(location) {
                    hole.hideMouse(animated: true)
                    showFloatingText("Nice! 🎉", at: hole.position,
                                     color: UIColor(Color(hex: "F0997B")))
                    gameDelegate?.tutorialTapSucceeded()
                    return
                }
            }
            return
        }

        guard isRunning, !isPaused2 else { return }

        for hole in holes where hole.isOccupied {
            if hole.containsTouch(location) {
                whackHole(hole)
                return
            }
        }
    }

    private func whackHole(_ hole: HoleNode) {
        hole.hideMouse(animated: true)
        combo += 1
        let hitBonus = combo >= 3
            ? currentPhase.scoreTickAmount * 15
            : currentPhase.scoreTickAmount * 8
        score += hitBonus
        gameDelegate?.scoreChanged(score: score)

        showFloatingText(
            "+\(hitBonus)", at: hole.position,
            color: combo >= 3
                ? UIColor(Color(hex: "D85A30"))
                : UIColor(Color(hex: "F0997B"))
        )

        if combo >= 3 && combo % 3 == 0 {
            showComboEffect()
            gameDelegate?.comboReached(combo: combo)
        }
    }

    private func handleMiss() {
        guard isRunning else { return }
        combo = 0
        lives -= 1
        gameDelegate?.livesChanged(lives: lives)

        let flash = SKSpriteNode(
            color: UIColor.red.withAlphaComponent(0.35),
            size: CGSize(width: size.width, height: size.height)
        )
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))

        if lives <= 0 { triggerGameOver() }
    }

    private func triggerGameOver() {
        stopEverything()

        for (i, hole) in holes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.07) {
                hole.showMouse(stayDuration: 99)
            }
        }

        let overlay = SKSpriteNode(
            color: UIColor.red.withAlphaComponent(0.0),
            size: CGSize(width: size.width, height: size.height)
        )
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 49
        addChild(overlay)
        overlay.run(SKAction.fadeAlpha(to: 0.4, duration: 0.5))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            guard let self else { return }
            let coins = self.coinsForScore(self.score)
            let xp = self.score / 50
            self.gameDelegate?.gameOver(score: self.score, coins: coins, xp: xp)
        }
    }

    private func coinsForScore(_ score: Int) -> Int {
        switch score {
        case 0..<500:     return score / 50
        case 500..<2000:  return 10 + (score - 500) / 40
        case 2000..<5000: return 47 + (score - 2000) / 30
        default:          return 147 + (score - 5000) / 20
        }
    }

    // MARK: - Visual FX

    private func showPhaseChangeEffect() {
        // Subtle white pulse to signal speed increase
        let flash = SKSpriteNode(
            color: UIColor.white.withAlphaComponent(0.0),
            size: CGSize(width: size.width, height: size.height)
        )
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 48
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.18, duration: 0.15),
            SKAction.fadeOut(withDuration: 0.35),
            SKAction.removeFromParent()
        ]))
    }

    private func showFloatingText(_ text: String, at position: CGPoint, color: UIColor) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 22
        label.fontColor = color
        label.position = CGPoint(x: position.x, y: position.y + 30)
        label.zPosition = 20
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 55, duration: 0.55),
                SKAction.fadeOut(withDuration: 0.55)
            ]),
            SKAction.removeFromParent()
        ]))
    }

    private func showComboEffect() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "🔥 \(combo)x combo!"
        label.fontSize = 28
        label.fontColor = UIColor(Color(hex: "F0997B"))
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        label.zPosition = 10
        label.setScale(0.5)
        label.alpha = 0
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeIn(withDuration: 0.15),
                SKAction.scale(to: 1.05, duration: 0.15)
            ]),
            SKAction.wait(forDuration: 0.8),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.scale(to: 0.8, duration: 0.25)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - HoleNode

final class HoleNode: SKNode {
    private(set) var isOccupied = false
    private let holeSize: CGFloat
    private let mouseSize: CGFloat
    private var mouseSprite: SKSpriteNode?
    private var hideTask: DispatchWorkItem?
    private var isFrozen = false
    private var frozenTimeRemaining: TimeInterval = 0
    private var freezeStart: Date?
    var onMissed: (() -> Void)?

    init(position: CGPoint, holeSize: CGFloat, mouseSize: CGFloat) {
        self.holeSize = holeSize
        self.mouseSize = mouseSize
        super.init()
        self.position = position
        setupHole()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupHole() {
        let hole = SKShapeNode(ellipseOf: CGSize(width: holeSize, height: holeSize * 0.38))
        hole.fillColor = UIColor(Color(hex: "5C3D2A")).withAlphaComponent(0.7)
        hole.strokeColor = .clear
        hole.zPosition = 1
        addChild(hole)
    }

    func showMouse(stayDuration: TimeInterval) {
        guard !isOccupied else { return }
        isOccupied = true
        isFrozen = false
        frozenTimeRemaining = stayDuration

        let sprite = makeMouseSprite()
        sprite.size = CGSize(width: mouseSize, height: mouseSize)
        sprite.position = CGPoint(x: 0, y: holeSize * 0.3)
        sprite.zPosition = 2
        sprite.setScale(0)
        mouseSprite = sprite
        addChild(sprite)

        sprite.run(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.07)
        ]))

        if stayDuration < 90 {
            scheduleHide(after: stayDuration)
        }
    }

    private func scheduleHide(after delay: TimeInterval) {
        hideTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard let self, !self.isFrozen else { return }
            self.onMissed?()
            self.hideMouse(animated: true)
        }
        hideTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }

    func freezeMouse() {
        guard isOccupied, !isFrozen else { return }
        isFrozen = true
        freezeStart = Date()
        hideTask?.cancel()
        hideTask = nil
        mouseSprite?.isPaused = true
    }

    func unfreezeMouse() {
        guard isOccupied, isFrozen else { return }
        isFrozen = false
        let elapsed = freezeStart.map { Date().timeIntervalSince($0) } ?? 0
        let remaining = max(0.3, frozenTimeRemaining - elapsed)
        mouseSprite?.isPaused = false
        scheduleHide(after: remaining)
    }

    func hideMouse(animated: Bool) {
        hideTask?.cancel()
        hideTask = nil
        guard isOccupied, let sprite = mouseSprite else { return }
        isOccupied = false
        isFrozen = false
        mouseSprite = nil

        if animated {
            sprite.run(SKAction.sequence([
                SKAction.scale(to: 0, duration: 0.12),
                SKAction.removeFromParent()
            ]))
        } else {
            sprite.removeFromParent()
        }
    }

    func containsTouch(_ point: CGPoint) -> Bool {
        guard isOccupied else { return false }
        let dx = point.x - position.x
        let dy = point.y - position.y
        let r = mouseSize * 0.55
        return dx * dx + dy * dy <= r * r
    }

    private func makeMouseSprite() -> SKSpriteNode {
        let texture = SKTexture(imageNamed: "Mouse")
        if texture.size().width > 1 {
            return SKSpriteNode(texture: texture)
        }
        let sz = CGSize(width: mouseSize, height: mouseSize)
        let renderer = UIGraphicsImageRenderer(size: sz)
        let image = renderer.image { _ in
            UIColor(Color(hex: "8B7B8B")).setFill()
            UIBezierPath(ovalIn: CGRect(x: 14, y: 20, width: 44, height: 36)).fill()
            UIColor(Color(hex: "9B8B9B")).setFill()
            UIBezierPath(ovalIn: CGRect(x: 22, y: 8, width: 32, height: 28)).fill()
            UIColor(Color(hex: "D4A0B0")).setFill()
            UIBezierPath(ovalIn: CGRect(x: 16, y: 4, width: 14, height: 14)).fill()
            UIBezierPath(ovalIn: CGRect(x: 42, y: 4, width: 14, height: 14)).fill()
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 26, y: 14, width: 8, height: 8)).fill()
            UIBezierPath(ovalIn: CGRect(x: 38, y: 14, width: 8, height: 8)).fill()
            UIColor.black.setFill()
            UIBezierPath(ovalIn: CGRect(x: 28, y: 16, width: 4, height: 4)).fill()
            UIBezierPath(ovalIn: CGRect(x: 40, y: 16, width: 4, height: 4)).fill()
            UIColor(Color(hex: "F0997B")).setFill()
            UIBezierPath(ovalIn: CGRect(x: 34, y: 26, width: 6, height: 5)).fill()
        }
        return SKSpriteNode(texture: SKTexture(image: image))
    }
}
