import Foundation
import SwiftData

// MARK: - Supporting Types

enum FurColor: String, Codable, CaseIterable {
    case orange
    case gray
    case black

    var assetName: String {
        switch self {
        case .orange: return "CatOrange"
        case .gray:   return "CatGray"
        case .black:  return "CatBlack"
        }
    }

    var displayName: String {
        switch self {
        case .orange: return "Orange"
        case .gray:   return "Gray"
        case .black:  return "Black"
        }
    }
}



enum AccessoryID: String, Codable, CaseIterable {
    case none
    case glasses
    case jacket
}

// MARK: - CatModel

@Model
final class CatModel {

    // Identity
    var name: String
    var furColor: FurColor

    // Stats (all 0.0 – 100.0)
    var hunger: Double
    var happiness: Double
    var cleanliness: Double
    var energy: Double

    // Progression
    var xp: Int
    var level: Int
    var coins: Int

    // Customization
    var equippedAccessory: AccessoryID

    // Inventory (food item IDs and quantities, stored as parallel arrays for SwiftData compatibility)
    var inventoryItemIDs: [String]
    var inventoryItemQuantities: [Int]

    // Persistence
    var lastSeen: Date

    // Onboarding
    var hasCompletedOnboarding: Bool

    init(
        name: String = "Calmm",
        furColor: FurColor = .orange,
    ) {
        self.name = name
        self.furColor = furColor
        self.hunger = 100
        self.happiness = 80
        self.cleanliness = 100
        self.energy = 100
        self.xp = 0
        self.level = 1
        self.coins = 50
        self.equippedAccessory = .none
        self.inventoryItemIDs = []
        self.inventoryItemQuantities = []
        self.lastSeen = Date()
        self.hasCompletedOnboarding = false
    }
}

// MARK: - Inventory Helpers

extension CatModel {

    /// Returns quantity of a food item in inventory. 0 if not present.
    func quantity(of itemID: String) -> Int {
        guard let index = inventoryItemIDs.firstIndex(of: itemID) else { return 0 }
        return inventoryItemQuantities[index]
    }

    /// Adds a quantity of a food item to inventory.
    func addToInventory(itemID: String, quantity: Int = 1) {
        if let index = inventoryItemIDs.firstIndex(of: itemID) {
            inventoryItemQuantities[index] += quantity
        } else {
            inventoryItemIDs.append(itemID)
            inventoryItemQuantities.append(quantity)
        }
    }

    /// Removes one unit of a food item from inventory. Returns true if successful.
    @discardableResult
    func consumeFromInventory(itemID: String) -> Bool {
        guard let index = inventoryItemIDs.firstIndex(of: itemID),
              inventoryItemQuantities[index] > 0 else { return false }

        inventoryItemQuantities[index] -= 1

        if inventoryItemQuantities[index] == 0 {
            inventoryItemIDs.remove(at: index)
            inventoryItemQuantities.remove(at: index)
        }

        return true
    }

    /// True if the player owns at least one of this food item.
    func hasItem(_ itemID: String) -> Bool {
        quantity(of: itemID) > 0
    }
}

// MARK: - XP / Level Helpers

extension CatModel {

    /// XP required to reach a given level (from level 1).
    static func xpRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + 500 * $1 }
    }

    /// XP needed to reach the next level from current total XP.
    var xpForNextLevel: Int {
        CatModel.xpRequired(forLevel: level + 1)
    }

    /// XP progress within the current level (0.0 – 1.0).
    var xpProgress: Double {
        let currentLevelXP = CatModel.xpRequired(forLevel: level)
        let nextLevelXP = CatModel.xpRequired(forLevel: level + 1)
        let range = nextLevelXP - currentLevelXP
        guard range > 0 else { return 1 }
        return Double(xp - currentLevelXP) / Double(range)
    }

    /// Call after awarding XP — updates level if threshold crossed.
    func recalculateLevel() {
        while xp >= CatModel.xpRequired(forLevel: level + 1) {
            level += 1
        }
    }
}
