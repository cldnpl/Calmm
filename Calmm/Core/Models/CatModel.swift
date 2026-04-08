import Foundation
import SwiftData

enum FurColor: String, Codable, CaseIterable {
    case orange
    case gray
    case black

    var assetName: String {
        switch self {
        case .orange:
            return "CatOrange"
        case .gray:
            return "CatGray"
        case .black:
            return "CatBlack"
        }
    }

    var displayName: String {
        switch self {
        case .orange:
            return "Orange"
        case .gray:
            return "Gray"
        case .black:
            return "Black"
        }
    }
}

@Model
final class CatModel {
    var name: String
    var furColor: FurColor
    var hunger: Double
    var cleanliness: Double
    var happiness: Double
    var energy: Double
    var xp: Int
    var level: Int
    var coins: Int
    var lastSeen: Date
    var ownedAccessoryIDsRaw: String?
    var equippedAccessoryID: String?
    var equippedAccessoryIDsRaw: String?
    var hasGrantedStarterCoins: Bool?
    var foodInventoryRaw: String?
    var hasGrantedStarterFood: Bool?
    var hasCompletedOnboarding: Bool

    init(
        name: String = "Calmm",
        furColor: FurColor = .orange
    ) {
        self.name = name
        self.furColor = furColor
        self.hunger = 100
        self.cleanliness = 100
        self.happiness = 80
        self.energy = 100
        self.xp = 0
        self.level = 1
        self.coins = 100
        self.lastSeen = Date()
        self.ownedAccessoryIDsRaw = ""
        self.equippedAccessoryID = nil
        self.equippedAccessoryIDsRaw = ""
        self.hasGrantedStarterCoins = true
        self.foodInventoryRaw = CatFoodCatalog.rawInventory(from: CatFoodCatalog.starterInventory)
        self.hasGrantedStarterFood = true
#if DEBUG
        self.hasCompletedOnboarding = GameConfig.debugSkipOnboarding
#else
        self.hasCompletedOnboarding = false
#endif
    }
}

extension CatModel {
    static func xpRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (1..<level).reduce(0) { $0 + 500 * $1 }
    }

    var xpForNextLevel: Int {
        CatModel.xpRequired(forLevel: level + 1)
    }

    var xpProgress: Double {
        let currentLevelXP = CatModel.xpRequired(forLevel: level)
        let nextLevelXP = CatModel.xpRequired(forLevel: level + 1)
        let range = nextLevelXP - currentLevelXP
        guard range > 0 else { return 1 }
        return Double(xp - currentLevelXP) / Double(range)
    }

    func recalculateLevel() {
        while xp >= CatModel.xpRequired(forLevel: level + 1) {
            level += 1
        }
    }
}
