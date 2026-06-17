import Foundation
import FirebaseFirestore

struct MarketProduct: Identifiable, Codable {
    let id: String
    var name: String
    var price: Double
    var quantity: Int
    let category: MarketCategory
    let iconName: String
    var description: String
    let sellerId: String
    let sellerName: String
    let createdAt: Date

    init(id: String = UUID().uuidString, name: String, price: Double, quantity: Int, category: MarketCategory, iconName: String, description: String, sellerId: String, sellerName: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.price = price
        self.quantity = quantity
        self.category = category
        self.iconName = iconName
        self.description = description
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.createdAt = createdAt
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

struct DeliveryAddress: Codable {
    let street: String
    let city: String
    let district: String
    let phone: String
}

struct CartItem: Identifiable {
    let id: String
    let productID: String
    let productName: String
    let productPrice: Double
    let productIcon: String
    let category: String
    let quantity: Int
    let sellerId: String
    let sellerName: String
    let addedAt: Date
}

struct ProductReview: Identifiable, Codable {
    let id: String
    let productId: String
    let farmerId: String
    let farmerName: String
    let rating: Int
    let comment: String
    let createdAt: Date
}

struct MarketOrder: Identifiable, Codable {
    let id: String
    let farmerId: String
    let farmerName: String
    let items: [OrderItem]
    let total: Double
    let address: DeliveryAddress
    let status: String
    let createdAt: Date
}

struct OrderItem: Codable {
    let productId: String
    let productName: String
    let price: Double
    let quantity: Int
    let sellerId: String
    let sellerName: String
}

enum MarketError: LocalizedError {
    case notLoggedIn
    case insufficientBalance
    case emptyCart
    case outOfStock

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "User not logged in"
        case .insufficientBalance: return "Insufficient balance to place order"
        case .emptyCart: return "Cart is empty"
        case .outOfStock: return "Product is out of stock"
        }
    }
}
