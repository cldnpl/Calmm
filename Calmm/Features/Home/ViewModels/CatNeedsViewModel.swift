import Foundation
import SwiftData
import SwiftUI

@Observable
final class CatNeedsViewModel {
    enum Need: Hashable {
        case hunger
        case cleanliness
        case happiness
    }

    private(set) var hunger: Double = 100
    private(set) var cleanliness: Double = 100
    private(set) var happiness: Double = 80

    private let hungerDecayPerSecond = GameConfig.hungerDecayPerSecond
    private let cleanlinessDecayPerSecond = GameConfig.cleanlinessDecayPerSecond
    private let happinessDecayPerSecond = GameConfig.happinessDecayPerSecond
    private let restoreTickDuration: Duration = .milliseconds(180)
    private let restorePointsPerTick = 1.2

    private var cat: CatModel?
    private var modelContext: ModelContext?
    private var decayTask: Task<Void, Never>?
    private var restorationTasks: [Need: Task<Void, Never>] = [:]

    var hungerPercentage: Double { hunger }
    var cleanlinessPercentage: Double { cleanliness }
    var happinessPercentage: Double { happiness }

    func connect(modelContext: ModelContext, cat: CatModel) {
        self.modelContext = modelContext
        self.cat = cat
        syncFromStorage(now: Date())
        startDecayLoopIfNeeded()
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            syncFromStorage(now: Date())
            startDecayLoopIfNeeded()
        case .inactive, .background:
            persistCurrentState(at: Date())
            stopDecayLoop()
        @unknown default:
            persistCurrentState(at: Date())
            stopDecayLoop()
        }
    }

    // MARK: - Public restore methods

    func feedCat(amount: Double = GameConfig.basicFoodHungerRestore) {
        startRestoration(for: .hunger, amount: amount)
    }

    func cleanCat(amount: Double = GameConfig.brushCleanlinessRestore) {
        startRestoration(for: .cleanliness, amount: amount)
    }

    func petCat(amount: Double = GameConfig.petHappinessRestore) {
        startRestoration(for: .happiness, amount: amount)
    }

    func loadPreview(hunger: Double, cleanliness: Double, happiness: Double = 80) {
        self.hunger = clamp(hunger)
        self.cleanliness = clamp(cleanliness)
        self.happiness = clamp(happiness)
    }

    // MARK: - Private

    private func syncFromStorage(now: Date) {
        guard let cat else { return }

        let elapsed = max(0, now.timeIntervalSince(cat.lastSeen))
        hunger     = clamp(cat.hunger      - elapsed * hungerDecayPerSecond)
        cleanliness = clamp(cat.cleanliness - elapsed * cleanlinessDecayPerSecond)
        happiness  = clamp(cat.happiness   - elapsed * happinessDecayPerSecond)
        persistCurrentState(at: now)
    }

    private func startDecayLoopIfNeeded() {
        guard decayTask == nil else { return }

        decayTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.applyDecay(seconds: 1)
            }
        }
    }

    private func stopDecayLoop() {
        decayTask?.cancel()
        decayTask = nil
    }

    private func applyDecay(seconds: TimeInterval) {
        hunger      = clamp(hunger      - seconds * hungerDecayPerSecond)
        cleanliness = clamp(cleanliness - seconds * cleanlinessDecayPerSecond)
        happiness   = clamp(happiness   - seconds * happinessDecayPerSecond)
        // No SwiftData write on every tick — persisted only on scene phase change
    }

    private func startRestoration(for need: Need, amount: Double) {
        guard amount > 0 else { return }

        restorationTasks[need]?.cancel()
        let target = min(100, value(for: need) + amount)
        let restoreTickDuration = self.restoreTickDuration

        restorationTasks[need] = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: restoreTickDuration)
                guard !Task.isCancelled else { break }
                let shouldContinue = self?.advanceRestoration(for: need, target: target) ?? false
                if !shouldContinue { break }
            }
            self?.finishRestoration(for: need)
        }
    }

    private func advanceRestoration(for need: Need, target: Double) -> Bool {
        let currentValue = value(for: need)
        guard currentValue < target else { return false }
        setValue(min(target, currentValue + restorePointsPerTick), for: need)
        return value(for: need) < target
    }

    private func finishRestoration(for need: Need) {
        restorationTasks[need] = nil
        persistCurrentState(at: Date())
    }

    private func value(for need: Need) -> Double {
        switch need {
        case .hunger:      return hunger
        case .cleanliness: return cleanliness
        case .happiness:   return happiness
        }
    }

    private func setValue(_ newValue: Double, for need: Need) {
        switch need {
        case .hunger:      hunger      = clamp(newValue)
        case .cleanliness: cleanliness = clamp(newValue)
        case .happiness:   happiness   = clamp(newValue)
        }
    }

    private func persistCurrentState(at date: Date) {
        guard let cat else { return }
        cat.hunger      = hunger
        cat.cleanliness = cleanliness
        cat.happiness   = happiness
        cat.lastSeen    = date
        try? modelContext?.save()
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0), 100)
    }
}
