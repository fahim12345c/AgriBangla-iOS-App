import Foundation

struct MarketProduct: Identifiable {
    let id: String
    let name: String
    let nameBN: String
    let price: Double
    var quantity: Int
    let category: MarketCategory
    let iconName: String
    let description: String
    let descriptionBN: String

    init(name: String, nameBN: String, price: Double, quantity: Int, category: MarketCategory, iconName: String, description: String, descriptionBN: String) {
        self.id = UUID().uuidString
        self.name = name
        self.nameBN = nameBN
        self.price = price
        self.quantity = quantity
        self.category = category
        self.iconName = iconName
        self.description = description
        self.descriptionBN = descriptionBN
    }

    enum MarketCategory: String, Codable, CaseIterable {
        case plant
        case medicine
        case fertilizer
        case equipment

        var sfSymbol: String {
            switch self {
            case .plant: return "leaf.fill"
            case .medicine: return "pills.fill"
            case .fertilizer: return "drop.fill"
            case .equipment: return "wrench.adjustable.fill"
            }
        }

        var color: String {
            switch self {
            case .plant: return "34C759"
            case .medicine: return "FF9500"
            case .fertilizer: return "5AC8FA"
            case .equipment: return "FF2D55"
            }
        }
    }
}

struct DeliveryAddress {
    let street: String
    let city: String
    let district: String
    let phone: String
}

struct CartItem: Identifiable {
    let id: String
    let productID: String
    let productName: String
    let productNameBN: String
    let productPrice: Double
    let productIcon: String
    let category: String
    let quantity: Int
    let addedAt: Date
}
