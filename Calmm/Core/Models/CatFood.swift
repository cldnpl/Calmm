import Foundation

struct CatFood: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Int
    let assetName: String
    let hungerRestoreAmount: Double
}

struct CatFoodInventoryEntry: Identifiable, Equatable {
    let food: CatFood
    let count: Int

    var id: String { food.id }
}

enum CatFoodCatalog {
    static let milk = CatFood(
        id: "milk",
        name: "Milk",
        price: 20,
        assetName: "Milk",
        hungerRestoreAmount: 18
    )

    static let donut = CatFood(
        id: "donut",
        name: "Donut",
        price: 35,
        assetName: "Donut",
        hungerRestoreAmount: 20
    )

    static let dryfish = CatFood(
        id: "dryfish",
        name: "Dryfish",
        price: 45,
        assetName: "Dryfish",
        hungerRestoreAmount: 30
    )

    static let fishfood = CatFood(
        id: "fishfood",
        name: "Fishfood",
        price: 30,
        assetName: "Fishfood",
        hungerRestoreAmount: 24
    )

    static let all: [CatFood] = [
        milk,
        donut,
        dryfish,
        fishfood
    ]

    static let starterInventory: [String: Int] = [
        milk.id: 2,
        dryfish.id: 2
    ]

    static func food(for id: String) -> CatFood? {
        all.first(where: { $0.id == id })
    }

    static func rawInventory(from inventory: [String: Int]) -> String {
        inventory
            .filter { $0.value > 0 }
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key):\($0.value)" }
            .joined(separator: ",")
    }

    static func inventory(from rawValue: String?) -> [String: Int] {
        var inventory: [String: Int] = [:]

        for pair in (rawValue ?? "").split(separator: ",") {
            let components = pair.split(separator: ":")
            guard components.count == 2 else { continue }

            let key = String(components[0])
            guard let value = Int(components[1]), value > 0 else { continue }
            inventory[key] = value
        }

        return inventory
    }
}
