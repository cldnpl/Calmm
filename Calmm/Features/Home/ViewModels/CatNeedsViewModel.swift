import Foundation
import SwiftData
import SwiftUI

@Observable
final class CatNeedsViewModel {
    enum Need: Hashable {
        case hunger
        case cleanliness
    }

    private(set) var hunger: Double = 100
    private(set) var cleanliness: Double = 100
    private(set) var coins: Int = 0
    private(set) var ownedAccessoryIDs: Set<String> = []
    private(set) var equippedAccessoryID: String?
    private(set) var foodInventory: [String: Int] = [:]
    var isFeedingModeActive = false

    // Local tester-only switch. Turn this off before shipping.
    private let testerInfiniteCoinsEnabled = true

    private let hungerDecayPerSecond = 1.0 / 90.0
    private let cleanlinessDecayPerSecond = 1.0 / 120.0
    private let restoreTickDuration: Duration = .milliseconds(180)
    private let restorePointsPerTick = 1.2

    private var cat: CatModel?
    private var modelContext: ModelContext?
    private var decayTask: Task<Void, Never>?
    private var restorationTasks: [Need: Task<Void, Never>] = [:]

    var hungerPercentage: Double { hunger }
    var cleanlinessPercentage: Double { cleanliness }
    var coinCount: Int { coins }
    var hasInfiniteCoins: Bool { testerInfiniteCoinsEnabled }
    var coinCountText: String {
        hasInfiniteCoins ? "∞ coins" : "\(coinCount) coins"
    }
    var equippedAccessory: CatAccessory? {
        CatAccessoryCatalog.accessory(for: equippedAccessoryID)
    }
    var availableFoods: [CatFoodInventoryEntry] {
        CatFoodCatalog.all.compactMap { food in
            let count = foodInventory[food.id, default: 0]
            guard count > 0 else { return nil }
            return CatFoodInventoryEntry(food: food, count: count)
        }
    }

    @discardableResult
    func spendCoins(_ amount: Int) -> Bool {
        guard spendCoinsIfPossible(amount) else { return false }
        persistCurrentState(at: Date())
        return true
    }

    @discardableResult
    func purchaseAccessory(id: String, price: Int) -> Bool {
        guard !ownedAccessoryIDs.contains(id) else { return true }
        guard spendCoinsIfPossible(price) else { return false }

        ownedAccessoryIDs.insert(id)
        persistCurrentState(at: Date())
        return true
    }

    func equipAccessory(id: String) {
        guard ownedAccessoryIDs.contains(id) else { return }
        guard equippedAccessoryID != id else { return }

        equippedAccessoryID = id
        persistCurrentState(at: Date())
    }

    func isAccessoryOwned(_ id: String) -> Bool {
        ownedAccessoryIDs.contains(id)
    }

    func isAccessoryEquipped(_ id: String) -> Bool {
        equippedAccessoryID == id
    }

    @discardableResult
    func purchaseFood(id: String, price: Int) -> Bool {
        guard CatFoodCatalog.food(for: id) != nil else { return false }
        guard spendCoinsIfPossible(price) else { return false }

        foodInventory[id, default: 0] += 1
        persistCurrentState(at: Date())
        return true
    }

    @discardableResult
    func feedCat(using foodID: String) -> Bool {
        guard let food = CatFoodCatalog.food(for: foodID) else { return false }
        guard foodInventory[foodID, default: 0] > 0 else { return false }

        foodInventory[foodID, default: 0] -= 1
        if foodInventory[foodID] == 0 {
            foodInventory.removeValue(forKey: foodID)
        }

        startRestoration(for: .hunger, amount: food.hungerRestoreAmount)
        persistCurrentState(at: Date())
        return true
    }

    func foodCount(for id: String) -> Int {
        foodInventory[id, default: 0]
    }

    func beginFeedingMode() {
        isFeedingModeActive = true
    }

    func endFeedingMode() {
        isFeedingModeActive = false
    }

    func toggleFeedingMode() {
        isFeedingModeActive.toggle()
    }

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

    func feedCat(amount: Double = 30) {
        startRestoration(for: .hunger, amount: amount)
    }

    func cleanCat(amount: Double = 25) {
        startRestoration(for: .cleanliness, amount: amount)
    }

    func loadPreview(hunger: Double, cleanliness: Double) {
        self.hunger = clamp(hunger)
        self.cleanliness = clamp(cleanliness)
        self.coins = 100
        self.ownedAccessoryIDs = []
        self.equippedAccessoryID = nil
        self.foodInventory = CatFoodCatalog.starterInventory
        self.isFeedingModeActive = false
    }

    private func syncFromStorage(now: Date) {
        guard let cat else { return }

        if cat.hasGrantedStarterCoins != true {
            cat.coins = max(cat.coins, 100)
            cat.hasGrantedStarterCoins = true
        }

        if cat.hasGrantedStarterFood != true {
            let existingInventory = CatFoodCatalog.inventory(from: cat.foodInventoryRaw)
            cat.foodInventoryRaw = CatFoodCatalog.rawInventory(
                from: mergedFoodInventory(existingInventory, with: CatFoodCatalog.starterInventory)
            )
            cat.hasGrantedStarterFood = true
        }

        let elapsed = max(0, now.timeIntervalSince(cat.lastSeen))
        hunger = clamp(cat.hunger - elapsed * hungerDecayPerSecond)
        cleanliness = clamp(cat.cleanliness - elapsed * cleanlinessDecayPerSecond)
        coins = cat.coins
        ownedAccessoryIDs = accessoryIDs(from: cat.ownedAccessoryIDsRaw)
        foodInventory = CatFoodCatalog.inventory(from: cat.foodInventoryRaw)
        equippedAccessoryID = ownedAccessoryIDs.contains(cat.equippedAccessoryID ?? "")
            ? cat.equippedAccessoryID
            : nil
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
        hunger = clamp(hunger - seconds * hungerDecayPerSecond)
        cleanliness = clamp(cleanliness - seconds * cleanlinessDecayPerSecond)
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
        persistCurrentState(at: Date())  // Save once when restoration animation completes
    }

    private func value(for need: Need) -> Double {
        switch need {
        case .hunger: return hunger
        case .cleanliness: return cleanliness
        }
    }

    private func setValue(_ newValue: Double, for need: Need) {
        switch need {
        case .hunger: hunger = clamp(newValue)
        case .cleanliness: cleanliness = clamp(newValue)
        }
    }

    private func persistCurrentState(at date: Date) {
        guard let cat else { return }

        cat.hunger = hunger
        cat.cleanliness = cleanliness
        cat.coins = coins
        cat.lastSeen = date
        cat.ownedAccessoryIDsRaw = rawAccessoryIDs(from: ownedAccessoryIDs)
        cat.equippedAccessoryID = ownedAccessoryIDs.contains(equippedAccessoryID ?? "")
            ? equippedAccessoryID
            : nil
        cat.foodInventoryRaw = CatFoodCatalog.rawInventory(from: foodInventory)
        cat.hasGrantedStarterCoins = true
        cat.hasGrantedStarterFood = true

        try? modelContext?.save()
    }

    private func spendCoinsIfPossible(_ amount: Int) -> Bool {
        if hasInfiniteCoins {
            return amount > 0
        }

        guard amount > 0, coins >= amount else { return false }

        coins -= amount
        return true
    }

    private func accessoryIDs(from rawValue: String?) -> Set<String> {
        Set((rawValue ?? "")
            .split(separator: ",")
            .map(String.init))
    }

    private func rawAccessoryIDs(from ids: Set<String>) -> String {
        ids.sorted().joined(separator: ",")
    }

    private func mergedFoodInventory(_ lhs: [String: Int], with rhs: [String: Int]) -> [String: Int] {
        var merged = lhs

        for (key, value) in rhs {
            merged[key, default: 0] += value
        }

        return merged
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0), 100)
    }
}
