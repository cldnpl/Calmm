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

    init(name: String = "Calmm") {
        self.name = name
        self.hunger = 100
        self.cleanliness = 100
        self.happiness = 80
        self.energy = 100
        self.xp = 0
        self.level = 1
        self.coins = 50
        self.lastSeen = Date()
    }
}
