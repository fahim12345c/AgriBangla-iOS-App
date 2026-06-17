import Foundation
import FirebaseFirestore
import FirebaseAuth

final class MarketService {
    static let shared = MarketService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Products

    func fetchProducts(category: MarketProduct.MarketCategory? = nil) async throws -> [MarketProduct] {
        var query: Query = db.collection("products")

        if let cat = category {
            query = query.whereField("category", isEqualTo: cat.rawValue)
        }

        query = query.order(by: "createdAt", descending: true)

        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MarketProduct.self)
        }
    }

    func addProduct(_ product: MarketProduct) async throws {
        try await db.collection("products").document(product.id).setData([
            "id": product.id,
            "name": product.name,
            "price": product.price,
            "quantity": product.quantity,
            "category": product.category.rawValue,
            "iconName": product.iconName,
            "description": product.description,
            "sellerId": product.sellerId,
            "sellerName": product.sellerName,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    func updateProduct(productId: String, name: String, price: Double, quantity: Int, description: String) async throws {
        try await db.collection("products").document(productId).updateData([
            "name": name,
            "price": price,
            "quantity": quantity,
            "description": description
        ])
    }

    func fetchOrders() async throws -> [MarketOrder] {
        let snapshot = try await db.collection("orders")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MarketOrder.self)
        }
    }

    // MARK: - Orders

    func createOrder(farmerId: String, farmerName: String, items: [CartItem], address: DeliveryAddress, total: Double, farmerBalance: Double) async throws -> String {
        let orderId = UUID().uuidString
        let orderItems: [[String: Any]] = items.map { item in
            [
                "productId": item.productID,
                "productName": item.productName,
                "price": item.productPrice,
                "quantity": item.quantity,
                "sellerId": item.sellerId,
                "sellerName": item.sellerName
            ]
        }

        try await db.collection("orders").document(orderId).setData([
            "id": orderId,
            "farmerId": farmerId,
            "farmerName": farmerName,
            "items": orderItems,
            "total": total,
            "farmerBalanceAtCheckout": farmerBalance,
            "address": [
                "street": address.street,
                "city": address.city,
                "district": address.district,
                "phone": address.phone
            ],
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ])

        return orderId
    }

    // MARK: - Balance

    func fetchBalance(userId: String) async throws -> Double {
        return try await FirestoreManager.shared.fetchUserBalance(userId: userId)
    }

    func deductBalance(userId: String, amount: Double) async throws {
        try await FirestoreManager.shared.addUserBalance(userId: userId, amount: -amount)
    }

    func addBalance(userId: String, amount: Double) async throws {
        try await FirestoreManager.shared.addUserBalance(userId: userId, amount: amount)
    }

    // MARK: - Atomic Order (batch write)

    func placeOrderAtomic(farmerId: String, farmerName: String, items: [CartItem], address: DeliveryAddress, total: Double) async throws -> String {
        let orderId = UUID().uuidString
        let orderItems: [[String: Any]] = items.map { item in
            [
                "productId": item.productID,
                "productName": item.productName,
                "price": item.productPrice,
                "quantity": item.quantity,
                "sellerId": item.sellerId,
                "sellerName": item.sellerName
            ]
        }

        let batch = db.batch()

        // 1. Create order
        let orderRef = db.collection("orders").document(orderId)
        batch.setData([
            "id": orderId,
            "farmerId": farmerId,
            "farmerName": farmerName,
            "items": orderItems,
            "total": total,
            "address": [
                "street": address.street,
                "city": address.city,
                "district": address.district,
                "phone": address.phone
            ],
            "status": "confirmed",
            "createdAt": FieldValue.serverTimestamp()
        ], forDocument: orderRef)

        // 2. Deduct from farmer
        let farmerRef = db.collection("users").document(farmerId)
        batch.updateData(["balance": FieldValue.increment(-total)], forDocument: farmerRef)

        // 3. Credit each seller & reduce product quantities
        var sellerTotals: [String: Double] = [:]
        for item in items {
            sellerTotals[item.sellerId, default: 0] += item.productPrice * Double(item.quantity)

            let productRef = db.collection("products").document(item.productID)
            batch.updateData(["quantity": FieldValue.increment(Int64(-item.quantity))], forDocument: productRef)
        }

        for (sellerId, amount) in sellerTotals {
            let sellerRef = db.collection("users").document(sellerId)
            batch.updateData(["balance": FieldValue.increment(amount)], forDocument: sellerRef)
        }

        try await batch.commit()
        return orderId
    }
}
