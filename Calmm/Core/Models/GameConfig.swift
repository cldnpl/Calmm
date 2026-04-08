//
//  GameConfig.swift
//  Calmm
//
//  Created by Raffaele Barra on 01/04/2026.
//


import Foundation

// MARK: - GameConfig
//
// Single source of truth for all tunable constants.
// NEVER hardcode these values inline in feature code.
// To tune the game economy, change values here only.

enum GameConfig {

    // MARK: - Stat Decay

    /// Hours for hunger to go from 100 → 0 while the app is closed.
    static let hungerDecayRateHours: Double = 18

    /// Hours for happiness to go from 100 → 0 while the app is closed.
    static let happinessDecayRateHours: Double = 18

    /// Hours for cleanliness to go from 100 → 0 while the app is closed.
    static let cleanlinessDecayRateHours: Double = 24

    // Derived per-second rates (used by CatNeedsViewModel — do not edit these)
    static let hungerDecayPerSecond: Double    = 100.0 / (hungerDecayRateHours * 3600)
    static let happinessDecayPerSecond: Double = 100.0 / (happinessDecayRateHours * 3600)
    static let cleanlinessDecayPerSecond: Double = 100.0 / (cleanlinessDecayRateHours * 3600)

    // MARK: - Notifications

    /// Stat value (0–100) below which a low-stat notification is sent.
    static let notificationThreshold: Double = 25

    // MARK: - Coin Rewards

    /// Coins earned when the player pets the cat (per gesture).
    static let petCoinReward: Int = 1

    /// Coins earned when the player feeds the cat.
    static let feedCoinReward: Int = 2

    /// Coins earned when the player brushes the cat.
    static let brushCoinReward: Int = 2

    /// Coins earned on daily login.
    static let dailyLoginBonus: Int = 50

    /// Coins earned when the cat levels up.
    static let levelUpCoinBonus: Int = 100

    // MARK: - XP Rewards

    /// XP earned per pet gesture.
    static let petXPReward: Int = 5

    /// XP earned when feeding the cat.
    static let feedXPReward: Int = 15

    /// XP earned when brushing the cat.
    static let brushXPReward: Int = 10

    // MARK: - Minigame Rewards

    /// Coins earned for completing Whack-a-Mole (base, before score multiplier).
    static let whackAMoleBaseCoinReward: Int = 20

    /// XP earned for completing Whack-a-Mole (base, before score multiplier).
    static let whackAMoleBaseXPReward: Int = 30

    /// Coins earned for completing the Platformer (base, before score multiplier).
    static let platformerBaseCoinReward: Int = 25

    /// XP earned for completing the Platformer (base, before score multiplier).
    static let platformerBaseXPReward: Int = 35

    // MARK: - Energy Costs

    /// Energy consumed when playing Whack-a-Mole.
    static let whackAMoleEnergyCost: Double = 15

    /// Energy consumed when playing the Platformer.
    static let platformerEnergyCost: Double = 20

    /// Energy consumed when entering a battle.
    static let battleEnergyCost: Double = 25

    /// Energy restored per second while the cat is idle (app open, no minigame).
    static let energyRestorePerSecond: Double = 100.0 / (4 * 3600) // full restore in 4 hours

    // MARK: - Battle

    /// Minimum cat level required to unlock the battle feature.
    static let minBattleLevel: Int = 3

    /// Minimum energy required to start a battle.
    static let minBattleEnergy: Double = 30

    /// Base HP for a level-1 cat. Scales with level.
    static let baseHP: Int = 100

    /// HP added per level.
    static let hpPerLevel: Int = 20

    // MARK: - Stat Restoration (care interactions)

    /// Hunger restored when feeding with a basic food item.
    static let basicFoodHungerRestore: Double = 30

    /// Happiness restored when petting.
    static let petHappinessRestore: Double = 15

    /// Cleanliness restored per brush gesture.
    static let brushCleanlinessRestore: Double = 25

    // MARK: - Shop Item Prices (coins)

    // Food
    static let basicFishPrice: Int = 10
    static let fancyTreatPrice: Int = 25
    static let milkPrice: Int = 15

    // Accessories
    static let glassesPrice: Int = 80
    static let jacketPrice: Int = 120

    // MARK: - Onboarding

    /// When true, skips onboarding and loads a default cat. Dev use only.
    #if DEBUG
    static let debugSkipOnboarding: Bool = false
    #endif
}