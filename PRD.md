# Product Requirements Document (PRD)

## Calmm — Virtual Pet Cat Game

**Version:** 1.0 (v1)
**Last Updated:** 2026-03-31
**Status:** In Development
**App Name:** TBD (cat-themed, working title "Calmm")

---

## 1. Overview

Calmm is a **Tamagotchi-style virtual pet game** where players raise, care for, and battle with a pixel-art cat. The game is designed as a passion project for learning game development, targeting **kids and pre-teens** on **iOS and iPadOS**.

The v1 experience is **fully offline**. Players create a cat, tend to its needs through direct interactions, play minigames to earn coins and XP, and battle computer-controlled opponent cats in a turn-based PvE system.

---

## 2. Target Audience

- **Primary:** Kids and pre-teens (ages 6-12)
- **Tone:** Friendly, playful, non-punitive (the cat cannot die or run away)
- **Content rating:** Suitable for all ages, no violent or mature content

---

## 3. Platforms & Technical Requirements

| Attribute | Value |
|---|---|
| Platforms | iOS, iPadOS |
| Minimum OS | iOS 18 |
| Orientation | Portrait (primary) |
| Monetization | None (v1) |
| Network | Fully offline |
| Save System | Single save slot, auto-save on every interaction |

### 3.1 Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Game & Animation | **SpriteKit** | Pixel art rendering, sprite animations, minigames, touch interactions |
| UI Shell | **SwiftUI** | Menus, shop, stats dashboard, settings, inventory |
| State Machines | **GameplayKit** | Cat mood/state management, battle AI |
| Persistence | **SwiftData** | Local save data (cat stats, inventory, currency, progression) |
| Audio | **AVFoundation** | Background music, sound effects via a shared audio manager |

All dependencies are first-party Apple frameworks. No external packages required.

---

## 4. Art Style

- **Pixel art** throughout the entire game
- The cat is represented by multiple discrete sprite states that are swapped/transitioned between to create animation
- All UI elements should complement the pixel art aesthetic

---

## 5. Core Gameplay Loop

```
Launch App
    |
    v
[First Launch] --> Cat Creation Flow --> Main Screen
[Returning]    --> Load Save + Calculate Stat Decay --> Main Screen
    |
    v
Main Screen (Cat + Stats)
    |
    +--> Care for Cat (Feed, Pet, Brush) --> Stats improve, small coin reward
    +--> Minigames (Whack-a-Mole, Platformer) --> Earn coins + XP
    +--> Shop --> Spend coins on food & accessories
    +--> Battle (PvE, turn-based) --> Earn XP, requires threshold to enter
    +--> Settings
    |
    v
Auto-save after every interaction
```

---

## 6. Features

### 6.1 Cat Creation & Onboarding

**First launch** presents a cat creation flow:

- **Choose fur color** from a preset palette
- **Choose eye color** from a preset palette
- **Name the cat** via text input
- Confirm and begin

**Debug mode:** A debug variable/flag in the codebase that, when enabled, skips onboarding entirely and loads a default cat. This is for development purposes only.

**Constraints:**
- Single cat per save (no multiple pets in v1)
- No growth stages — the cat remains visually the same throughout (aside from accessories)
- The cat **cannot die or run away** under any circumstances

---

### 6.2 Main Screen

The main screen displays the cat in its environment with visible stat indicators.

**Cat display:**
- Pixel art cat rendered via SpriteKit, embedded in SwiftUI via `SpriteView`
- The cat is interactive and responds to touch

**Direct interactions on the main screen:**

| Interaction | Gesture | Effect |
|---|---|---|
| **Pet** | Swipe across the cat | Increases happiness; triggers purring animation |
| **Feed** | Tap feed button → inventory wheel appears at screen bottom → drag food item onto the cat | Increases hunger stat (amount varies by food type); food item consumed from inventory |
| **Brush** | Drag brush icon over the cat | Increases hygiene stat |

**Inventory wheel (feeding):**
- Triggered by tapping a feed button on the main screen
- Displays a radial or horizontal wheel of food items currently in inventory
- Player drags desired food item to the cat to feed it
- Wheel dismisses after feeding or on tap-away

---

### 6.3 Stats System

| Stat | Range | Decay When Closed? | Notes |
|---|---|---|---|
| **Hunger** | 0 – 100 | Yes (12-24 hr full→empty) | Restored by feeding |
| **Happiness** | 0 – 100 | Yes (12-24 hr full→empty) | Restored by petting, minigames |
| **Energy** | 0 – 100 | No | Consumed by minigames/battles, restores over time while idle |
| **Hygiene** | 0 – 100 | No | Restored by brushing |
| **XP** | 0 – ∞ | No | Earned from minigames, battles, care tasks, leveling bonuses |
| **Level** | 1 – ∞ | No | Derived from XP thresholds |
| **HP** | 0 – max | Battle only | Used in battle; determined by cat's stats/level |

**Stat decay (offline calculation):**
- When the app launches, calculate elapsed time since last save
- Apply hunger and happiness decay proportionally
- Decay rate: configurable constant (target: full-to-empty in 12-24 hours)
- Stats clamp at 0 (never go negative)

**Notifications:**
- When hunger or happiness drops below a threshold (e.g., 25%), send a gentle local notification: *"Your cat is hungry!"* / *"Your cat misses you!"*
- Notifications respect the user's toggle in settings

---

### 6.4 Cat Sprite States (v1)

The following pixel art states exist for the cat:

| State | Trigger |
|---|---|
| **Happy idle** (default) | Normal state, stats are healthy |
| **Sad** | Hunger or happiness is low |
| **Angry** | Triggered contextually (e.g., hunger critically low) |
| **Purring / happy** | When player pets the cat |
| **Wearing glasses** | Accessory equipped |
| **Wearing jacket** | Accessory equipped |

Accessory states overlay on top of the base emotional state. The cat can be sad AND wearing glasses simultaneously.

---

### 6.5 Economy & Currency

**Currency:** Coins (single currency, integer value)

**Earning coins:**

| Source | Amount |
|---|---|
| Minigame completion | Medium reward (configurable) |
| Daily login bonus | Small-medium reward (configurable) |
| Completing care tasks (feed, brush, pet) | Tiny reward (configurable) |
| Leveling up | Large reward (configurable) |

All coin values should be defined as **easily configurable constants** in a central configuration file so the economy can be tuned without code changes across multiple files.

**Spending coins:**
- Food items (consumable)
- Accessories (permanent, one-time purchase)
- *Future:* room decorations, furniture

---

### 6.6 Shop

- **Always available** from the main screen (no level gate)
- **Categories:** Food, Accessories (*expandable for future categories*)
- **Inventory:** Unlimited — no cap on how many items the player can own
- **Food items** are consumed on use and disappear from inventory
- **Accessories** are permanent once purchased; can be equipped/unequipped freely
- The shop data model should be **easily extensible** to add new item categories (e.g., decorations) in the future without architectural changes

---

### 6.7 Cat Customization

**At creation:**
- Fur color (preset palette)
- Eye color (preset palette)

**Post-creation (via shop purchases):**
- Accessories: glasses, jacket (v1), with more addable in the future (hats, scarves, collars, etc.)
- Accessories can be equipped and unequipped from an inventory/wardrobe screen

**Future (not v1):**
- Visual evolution based on level (e.g., crown at level 10)
- Room/environment decoration

---

### 6.8 Minigames

Two minigames for v1, both played in SpriteKit scenes:

#### 6.8.1 Whack-a-Mole
- Moles (or mice/fish, themed to fit) pop up from holes
- Player taps to whack them before they disappear
- Score determines coin and XP reward
- Increasing difficulty over time (faster, more targets)

#### 6.8.2 2D Platformer Obstacle Course
- Side-scrolling or vertical platformer
- Cat sprite jumps between platforms, avoids obstacles
- Distance/score determines coin and XP reward
- Simple tap/swipe controls appropriate for kids

**Minigame access:**
- Some minigames are available from the start
- Additional minigames unlock as the cat levels up
- The minigame system should be architected so new minigames can be added easily (protocol/interface-based)

**Rewards:**
- Coins and XP awarded at end of each session based on score
- Reward formulas should be configurable constants

---

### 6.9 Battle System (PvE — v1)

#### Entry Requirements
- Cat must meet a minimum XP/level threshold to unlock battles
- Cat must have a minimum HP/fitness level to start a battle

#### Battle Flow
1. Player selects "Battle" from main screen
2. Matchmaking selects a computer-controlled opponent cat (difficulty based on player's level)
3. Turn-based combat begins

#### Combat Mechanics
- **Turn-based:** Player and opponent alternate turns
- **Moves:** Each turn, the player selects a move (e.g., Scratch, Pounce, Hiss, Defend)
- **Move effectiveness** is tied to the cat's stats (higher stats = more damage/defense)
- **HP system:** Both cats have HP; damage reduces HP; cat at 0 HP loses
- **Outcome:** Win → earn XP and coins; Lose → no penalty (kid-friendly, no punishment)

#### Opponent Scaling
- Computer opponents scale in difficulty as the player's cat levels up
- Higher-level opponents have better stats and smarter move selection (GameplayKit AI)

#### Future (v2)
- Online PvP battles against other players
- Matchmaking, leaderboards, friend battles

---

### 6.10 Audio System

**Architecture:**
- **Shared audio manager** (singleton) responsible for all audio playback
- Supports **fade-in and fade-out** transitions for music
- Reuses audio instances rather than creating new ones per interaction
- **Placeholder system:** All audio call sites reference named audio assets; missing assets play silence gracefully without crashes

**Audio content:**

| Context | Type | Notes |
|---|---|---|
| Main screen | Background music | Loops, calm/playful tone |
| Minigames | Per-minigame music | Distinct from main screen |
| Feeding | Sound effect | Eating/crunching sound |
| Petting | Sound effect | Purring |
| Brushing | Sound effect | Brushing swoosh |
| Battle | Sound effects | Hit sounds, victory/defeat jingles |
| UI | Sound effects | Button taps, shop purchase, level up |

**Controls:**
- Mute toggle in settings (persisted across sessions)
- When muted, all audio (music + SFX) is silenced

*Note: Audio assets are not yet available. The system should be built with placeholder references so assets can be dropped in without code changes.*

---

### 6.11 Settings Screen

Accessible from the main screen. Contains:

| Setting | Type | Behavior |
|---|---|---|
| **Sound** | Toggle | Mute/unmute all audio |
| **Notifications** | Toggle | Enable/disable local notifications |
| **Reset Game** | Button | Prompts a **confirmation dialog** with a clear warning ("This will delete all progress. Are you sure?"). On confirm, wipes all save data and returns to cat creation flow |

---

### 6.12 Save System

- **Single save slot** — one cat, one profile per device
- **Auto-save** triggered after every meaningful interaction (feeding, petting, brushing, minigame completion, battle completion, shop purchase, equipping accessories)
- **Persistence layer:** SwiftData with a local store
- **Data saved:** Cat appearance, name, all stats, inventory, equipped accessories, coin balance, XP/level, settings preferences, last-active timestamp (for decay calculation)

---

## 7. Notifications

- **Type:** Local notifications only (no push notification server)
- **Triggers:** Hunger or happiness dropping below configurable threshold
- **Tone:** Gentle, friendly messages ("Your cat misses you! Come say hi!")
- **Respect user toggle:** If notifications are disabled in settings, no notifications are scheduled
- **Frequency cap:** No more than one notification per stat per decay cycle to avoid spamming

---

## 8. Screen Map

```
App Launch
    |
    +-- [First Launch] --> Cat Creation Screen
    |                          |
    |                          v
    +-- [Returning] --------> Main Screen
                                |
                                +-- Stats Display (always visible)
                                +-- Cat (interactive SpriteKit scene)
                                +-- Feed Button --> Inventory Wheel (overlay)
                                +-- Minigames Button --> Minigame Select --> Whack-a-Mole
                                |                                       --> Platformer
                                +-- Battle Button --> Battle Screen (turn-based combat)
                                +-- Shop Button --> Shop Screen (Food / Accessories tabs)
                                +-- Wardrobe/Customize Button --> Accessory equip screen
                                +-- Settings Button --> Settings Screen
```

---

## 9. Data Model (High-Level)

```
Cat
├── name: String
├── furColor: Color
├── eyeColor: Color
├── hunger: Double (0-100)
├── happiness: Double (0-100)
├── energy: Double (0-100)
├── hygiene: Double (0-100)
├── xp: Int
├── level: Int (derived from XP)
├── coins: Int
├── lastActiveTimestamp: Date
├── equippedAccessories: [Accessory]
└── inventory: [InventoryItem]

InventoryItem
├── item: ShopItem
├── quantity: Int (for consumables)
└── type: food | accessory

ShopItem
├── id: String
├── name: String
├── category: food | accessory
├── price: Int (coins)
├── effects: [StatEffect] (e.g., hunger +30, happiness +10)
└── spriteAssetName: String

BattleOpponent
├── name: String
├── level: Int
├── stats: CatStats
├── moves: [BattleMove]
└── spriteAssetName: String

BattleMove
├── name: String
├── damage: Int
├── statModifier: StatType (which cat stat influences this move)
└── type: attack | defend
```

---

## 10. Configuration & Tuning

The following values must be defined as **named constants in a central config file** for easy tuning:

| Constant | Description | Initial Value |
|---|---|---|
| `hungerDecayRate` | Hours for hunger to go full→empty | 18 |
| `happinessDecayRate` | Hours for happiness to go full→empty | 18 |
| `notificationThreshold` | Stat level that triggers notification | 25 |
| `minBattleLevel` | Minimum cat level to unlock battles | TBD |
| `minBattleHP` | Minimum HP to start a battle | TBD |
| `dailyLoginBonus` | Coins earned on daily login | TBD |
| `careTaskCoinReward` | Coins earned per care interaction | TBD |
| `levelUpCoinBonus` | Coins earned on level up | TBD |
| `xpPerLevel` | XP thresholds per level (formula or table) | TBD |

All `TBD` values are to be determined during playtesting and balancing.

---

## 11. Out of Scope (v1)

The following are explicitly **not included** in v1 but are acknowledged as future goals:

| Feature | Target Version |
|---|---|
| Online PvP battles | v2 |
| Multiple cats / profiles | v2+ |
| Cat growth stages / visual evolution | v2+ |
| Room decoration / furniture | v2+ |
| In-app purchases / monetization | v2+ |
| Cloud saves / cross-device sync | v2+ |
| Leaderboards | v2+ |
| watchOS / macOS support | v2+ |
| Multiple save slots | v2+ |
| Additional minigames beyond 2 | v2+ |

---

## 12. Architecture & Engineering Decisions

This section is **mandatory reading for any engineer or AI agent working on this codebase.** All decisions here have been deliberately chosen and must be adhered to. Do not deviate without explicit confirmation from the project owner.

---

### 12.1 Project File Structure

The project uses a **feature-based architecture**, not a layer-based one (i.e., not a flat `Views/`, `ViewModels/`, `Models/` split).

```
Calmm/                              ← Xcode source root (PBXFileSystemSynchronizedRootGroup)
├── App/                            ← App entry point and root navigation shell
│   ├── CalmmApp.swift
│   ├── ContentView.swift
│   └── Root/
│       ├── RootView.swift
│       └── RootViewModel.swift
├── Core/                           ← Shared infrastructure — no feature-specific UI here
│   ├── Audio/AudioManager.swift
│   ├── Config/GameConfig.swift     ← All tunable constants (economy, decay rates, thresholds)
│   ├── Extensions/Color+Hex.swift
│   ├── Models/CatModel.swift       ← SwiftData @Model — single source of truth for cat data
│   ├── Navigation/
│   │   ├── AppTab.swift
│   │   └── CustomTabBar.swift
│   ├── Notifications/NotificationManager.swift
│   └── Services/StatDecayService.swift
├── Features/                       ← Each feature is self-contained (views + viewmodels + feature models)
│   ├── Onboarding/
│   ├── Home/
│   │   ├── Views/   (HomeView, CatSceneView, CatNeedsOverlayView, NeedProgressBar, InventoryWheelView)
│   │   └── ViewModels/   (HomeViewModel, CatNeedsViewModel)
│   ├── Minigames/
│   │   ├── Shared/   (MinigameProtocol, MinigameSelectView, MinigameResultView)
│   │   ├── WhackAMole/   (WhackAMoleScene [SKScene], WhackAMoleView)
│   │   └── Platformer/   (PlatformerScene [SKScene], PlatformerView)
│   ├── Battle/
│   │   ├── Models/   (BattleMove, BattleOpponent)
│   │   ├── Views/    (BattleView)
│   │   └── ViewModels/   (BattleViewModel)
│   ├── Shop/Views/ + ViewModels/
│   ├── Style/Views/ + ViewModels/
│   ├── Profile/Views/ + ViewModels/
│   └── Settings/
├── SharedUI/                       ← Reusable UI components used across multiple features
└── Resources/
    ├── Assets.xcassets
    └── Audio/                      ← All audio files (.mp3, .m4a, .wav, .caf)
```

**Rule:** Adding a new feature means adding a folder under `Features/`. Do not create new top-level layer folders (e.g., do not add a new `Views/` or `Models/` at the root level).

**Rule:** Adding a new minigame means adding a subfolder under `Features/Minigames/` that conforms to `MinigameProtocol`. No changes to other features required.

---

### 12.2 Xcode Project Configuration

**`PBXFileSystemSynchronizedRootGroup` is used** (Xcode 16 feature). This means:
- Xcode **automatically tracks all files** inside the `Calmm/` source directory
- **No `.pbxproj` editing is required** when adding, moving, or renaming files
- Simply create or move files on disk — Xcode will pick them up on next open

**Build settings of note (set in `project.pbxproj`):**
- `IPHONEOS_DEPLOYMENT_TARGET = 26.0` — This project targets **iOS 26**, not iOS 18. Use iOS 26 APIs freely.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — **All types in this module are implicitly `@MainActor`.** Explicit `@MainActor` annotations are redundant but acceptable for clarity.
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` — Approachable concurrency mode is on.
- `TARGETED_DEVICE_FAMILY = 1,2` — iPhone and iPad.

---

### 12.3 State Management — `@Observable` Only

**Always use `@Observable` instead of `ObservableObject`.** `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, and `@EnvironmentObject` are the legacy pre-iOS 17 pattern. This project targets iOS 26 — there is no reason to use the legacy pattern.

| Pattern | Correct (use this) | Incorrect (never use) |
|---|---|---|
| Observable class | `@Observable final class MyVM {}` | `class MyVM: ObservableObject {}` |
| Owned in a view | `@State private var vm = MyVM()` | `@StateObject private var vm = MyVM()` |
| Injected, needs bindings | `@Bindable var vm: MyVM` | `@ObservedObject var vm: MyVM` |
| Environment injection | `.environment(myObj)` | `.environmentObject(myObj)` |
| Environment consumption | `@Environment(MyType.self) private var obj` | `@EnvironmentObject var obj: MyType` |

**All `@State` properties must be `private`.** Never pass an initial value into `@State` — it only accepts the initial value and ignores subsequent updates from the parent.

---

### 12.4 SwiftUI API Versions

Since the deployment target is **iOS 26**, use the latest available APIs everywhere. Key rules:

| Deprecated (never use) | Correct (always use) |
|---|---|
| `onChange(of:perform:)` | `onChange(of:) { }` or `onChange(of:) { old, new in }` |
| `foregroundColor()` | `foregroundStyle()` |
| `cornerRadius()` | `clipShape(.rect(cornerRadius:))` |
| `NavigationView` | `NavigationStack` / `NavigationSplitView` |
| `tabItem(_:)` | `Tab` API (iOS 18+) — **except** for `CustomTabBar` which is intentionally custom |
| `accentColor()` | `tint()` |
| `animation(_:)` without value | `animation(_:value:)` |
| `alert(isPresented:content:)` | `alert(_:isPresented:actions:message:)` |
| `actionSheet` | `confirmationDialog` |

**Custom Tab Bar:** The app uses a fully custom `CustomTabBar` (pixel-art aesthetic, raised centre button). Do **not** replace it with the native `Tab` API — this is intentional by design.

---

### 12.5 SpriteKit Integration

- Always use **`SpriteView(scene:)`** to embed SpriteKit content in SwiftUI. Do **not** wrap `SKView` in `UIViewRepresentable` — `SpriteView` is the native SwiftUI API (iOS 14+) and is sufficient.
- Each minigame is an `SKScene` subclass housed in its own `Features/Minigames/<Name>/` folder.
- `CatSceneView` is the designated abstraction boundary for the home-screen cat. When the cat is migrated from static images to a full SpriteKit scene, it happens inside `CatSceneView` — no other files change.

---

### 12.6 Data Model Rules

**`CatModel` fields use `Double` for all percentage-based stats.** There is no `Int` counterpart or `*Progress` shadow field. The old `hunger: Int` + `hungerProgress: Double` split was a bug and has been removed.

```swift
// Correct
var hunger: Double      // 0.0 – 100.0
var cleanliness: Double
var happiness: Double
var energy: Double

// Never do this again
var hunger: Int            // ❌ redundant
var hungerProgress: Double // ❌ redundant
```

**`CatModel` is the only SwiftData `@Model`.** Feature-specific types (e.g., `BattleMove`, `BattleOpponent`, `ShopItem`) are plain Swift structs/classes, not SwiftData models, unless persistence of that data is explicitly required.

---

### 12.7 Persistence & SwiftData Write Strategy

**Do not write to SwiftData on every timer tick.** The decay loop fires every second — writing on every tick causes unnecessary disk I/O and battery drain on kids' devices.

**Correct write triggers:**
1. `scenePhase` changes to `.background` or `.inactive` — flush current state
2. Restoration animation completes (player fed / brushed the cat) — save the result once
3. `scenePhase` changes to `.active` — read from storage, calculate elapsed time decay, write the corrected values back once

**Never write inside `applyDecay()`.** In-memory state updates freely; disk writes are gated.

---

### 12.8 Audio System

- **`AudioManager.shared`** is the single point of contact for all audio. Never instantiate a per-interaction audio player.
- Audio files live in `Resources/Audio/`. Reference them by name string — missing files must fail silently (no crash).
- The audio manager must support fade-in/fade-out for music transitions (not yet implemented — add when assets are available).
- A mute toggle (persisted in settings) must silence all audio, both music and SFX.
- **Placeholder pattern:** All audio call sites must still compile and run when audio files are absent. `AudioManager` handles the graceful no-op internally.

---

### 12.9 Economy Tuning

All coin reward values, XP thresholds, decay rates, notification thresholds, and battle unlock requirements must be defined as **named constants in `Core/Config/GameConfig.swift`**. Never hard-code these values inline in feature code.

```swift
// Correct — in GameConfig.swift
enum GameConfig {
    static let hungerDecayRateHours: Double = 18
    static let dailyLoginBonus: Int = 50
    // ...
}

// Never do this
let decay = 1.0 / (18 * 3600) // ❌ magic number inline
```

---

### 12.10 Extensibility Contracts

These patterns must be maintained as the project grows:

| Extension point | How to extend |
|---|---|
| New minigame | Add `Features/Minigames/<Name>/` with an `SKScene` subclass conforming to `MinigameProtocol` |
| New shop item category | Add a new `case` to `ShopItem.category` enum — `ShopView` iterates categories dynamically |
| New cat accessory | Add an asset to `Assets.xcassets` and an entry to the accessory data source — no view code changes |
| New stat | Add a `Double` field to `CatModel`, add decay/restore logic to `CatNeedsViewModel`, add a `NeedProgressBar` entry |
| New tab | Add a `case` to `AppTab` enum — `CustomTabBar` and `RootView` iterate `AppTab.allCases` |

---

## 13. Success Criteria

Since this is a passion/learning project, success is measured by:

1. **Functional core loop:** Player can create a cat, care for it, play minigames, and battle AI opponents without crashes
2. **Stat system works correctly:** Hunger/happiness decay offline and recover through interactions
3. **Economy is functional:** Coins flow in and out; shop works; items are consumed/equipped correctly
4. **Persistence is reliable:** Game state survives app restarts, background/foreground cycles, and device restarts
5. **Kid-friendly UX:** Interactions are intuitive via drag/swipe; no frustrating penalties; gentle notifications
6. **Extensible architecture:** New items, minigames, and features can be added without major refactors
