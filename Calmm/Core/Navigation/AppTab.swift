import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case games
    case shop
    case home
    case style
    case profile

    var id: Int { rawValue }

    var iconName: String {
        switch self {
        case .games:
            return "gamecontroller.fill"
        case .shop:
            return "bag.fill"
        case .home:
            return "house.fill"
        case .style:
            return "tshirt.fill"
        case .profile:
            return "star.fill"
        }
    }

    var title: String {
        switch self {
        case .games:
            return "games"
        case .shop:
            return "shop"
        case .home:
            return "kennel"
        case .style:
            return "wardrobe"
        case .profile:
            return "profile"
        }
    }

    var isCenterTab: Bool {
        self == .home
    }
}
