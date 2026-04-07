import Foundation
import SwiftData

@Model
final class CatModel {
    var name: String
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

    init(name: String = "Calmm") {
        self.name = name
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
    }
}
