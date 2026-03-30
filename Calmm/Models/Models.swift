//
//  Models.swift
//  Calmm
//
//  Created by Raffaele Barra on 30/03/2026.
//

import Foundation
import SwiftData

@Model
class CatModel {
    var name: String
    var hunger: Int
    var happiness: Int
    var energy: Int
    var xp: Int
    var level: Int
    var coins: Int
    var lastSeen: Date

    init(name: String = "Calmm") {
        self.name = name
        self.hunger = 80
        self.happiness = 80
        self.energy = 100
        self.xp = 0
        self.level = 1
        self.coins = 50
        self.lastSeen = Date()
    }
}




