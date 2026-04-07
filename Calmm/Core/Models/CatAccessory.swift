import Foundation

struct CatAccessory: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Int
    let assetName: String
}

enum CatAccessoryCatalog {
    static let frogHat = CatAccessory(
        id: "frog-hat",
        name: "Frog Hat",
        price: 45,
        assetName: "Froghat"
    )

    static let witchHat = CatAccessory(
        id: "witch-hat",
        name: "Witch Hat",
        price: 55,
        assetName: "Witchhat"
    )

    static let all: [CatAccessory] = [
        frogHat,
        witchHat
    ]

    static func accessory(for id: String?) -> CatAccessory? {
        guard let id else { return nil }
        return all.first(where: { $0.id == id })
    }
}
