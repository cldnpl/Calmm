import Foundation

enum CatAccessorySlot: String, CaseIterable {
    case head
    case face
    case outfit

    var renderOrder: Int {
        switch self {
        case .outfit: return 0
        case .face: return 1
        case .head: return 2
        }
    }
}

struct CatAccessory: Identifiable, Equatable {
    let id: String
    let name: String
    let price: Int
    let assetName: String
    let slot: CatAccessorySlot
}

enum CatAccessoryCatalog {
    static let frogHat = CatAccessory(
        id: "frog-hat",
        name: "Frog Hat",
        price: 45,
        assetName: "Froghat",
        slot: .head
    )

    static let witchHat = CatAccessory(
        id: "witch-hat",
        name: "Witch Hat",
        price: 55,
        assetName: "Witchhat",
        slot: .head
    )

    static let gryffindorJacket = CatAccessory(
        id: "gryffindor-jacket",
        name: "Gryffindor Jacket",
        price: 90,
        assetName: "Jacketgrif",
        slot: .outfit
    )

    static let hufflepuffJacket = CatAccessory(
        id: "hufflepuff-jacket",
        name: "Hufflepuff Jacket",
        price: 90,
        assetName: "Jackethuf",
        slot: .outfit
    )

    static let ravenJacket = CatAccessory(
        id: "raven-jacket",
        name: "Raven Jacket",
        price: 90,
        assetName: "Jacketrew",
        slot: .outfit
    )

    static let slyJacket = CatAccessory(
        id: "sly-jacket",
        name: "Sly Jacket",
        price: 90,
        assetName: "Jacketsly",
        slot: .outfit
    )

    static let blueGlasses = CatAccessory(
        id: "blue-glasses",
        name: "Blue Glasses",
        price: 60,
        assetName: "Glassblue",
        slot: .face
    )

    static let greenGlasses = CatAccessory(
        id: "green-glasses",
        name: "Green Glasses",
        price: 60,
        assetName: "Glassgreen",
        slot: .face
    )

    static let redGlasses = CatAccessory(
        id: "red-glasses",
        name: "Red Glasses",
        price: 60,
        assetName: "Glassred",
        slot: .face
    )

    static let yellowGlasses = CatAccessory(
        id: "yellow-glasses",
        name: "Yellow Glasses",
        price: 60,
        assetName: "Glassyellow",
        slot: .face
    )

    static let all: [CatAccessory] = [
        frogHat,
        witchHat,
        gryffindorJacket,
        hufflepuffJacket,
        ravenJacket,
        slyJacket,
        blueGlasses,
        greenGlasses,
        redGlasses,
        yellowGlasses
    ]

    static func accessory(for id: String?) -> CatAccessory? {
        guard let id else { return nil }
        return all.first(where: { $0.id == id })
    }
}
