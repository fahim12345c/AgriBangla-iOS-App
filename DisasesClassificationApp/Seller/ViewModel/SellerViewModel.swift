import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class SellerViewModel: ObservableObject {
    @Published var userName = ""
    @Published var userBalance: Double = 0
    @Published var totalProducts: Int = 0
    @Published var totalOrders: Int = 0
    @Published var totalEarned: Double = 0
    @Published var categorySales: [(String, Double)] = []
    @Published var reviews: [ProductReview] = []
    @Published var averageRating: Double = 0
    @Published var reviewCount: Int = 0
    @Published var myProducts: [MarketProduct] = []
    @Published var orders: [MarketOrder] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var toastMessage: String?
    @Published var editingProductId: String?
    @Published var editName = ""
    @Published var editPrice = ""
    @Published var editQuantity = ""
    @Published var editDescription = ""

    private let marketService = MarketService.shared
    private let reviewService = MarketReviewService.shared
    private let firestoreManager = FirestoreManager.shared

    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        do {
            if let user = try await firestoreManager.fetchUser(userId: uid) {
                userName = [user.firstName, user.lastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
                userBalance = user.balance
            }

            let allProducts = try await marketService.fetchProducts()
            myProducts = allProducts.filter { $0.sellerId == uid }
            totalProducts = myProducts.count

            let allOrders = try await marketService.fetchOrders()
            orders = allOrders.filter { order in
                order.items.contains { $0.sellerId == uid }
            }
            let confirmedOrders = allOrders.filter { $0.status.lowercased() == "confirmed" }

            var earned: Double = 0
            var catSales: [String: Double] = [:]
            var orderCount = 0

            for doc in confirmedOrders {
                let sellerItems = doc.items.filter { $0.sellerId == uid }
                if !sellerItems.isEmpty {
                    orderCount += 1
                }
                for item in sellerItems {
                    earned += item.price * Double(item.quantity)
                }
            }

            for product in myProducts {
                catSales[product.category.rawValue, default: 0] += 0
            }

            for order in confirmedOrders {
                for item in order.items {
                    guard let product = myProducts.first(where: { $0.id == item.productId }) else { continue }
                    catSales[product.category.rawValue, default: 0] += item.price * Double(item.quantity)
                }
            }

            totalOrders = orderCount
            totalEarned = earned
            categorySales = catSales.map { ($0.key, $0.value) }.sorted { $0.1 > $1.1 }

            reviews = try await reviewService.fetchAllReviewsForSeller(sellerId: uid)
            reviewCount = reviews.count
            averageRating = reviews.isEmpty ? 0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func beginEdit(_ product: MarketProduct) {
        editingProductId = product.id
        editName = product.name
        editPrice = String(format: "%.0f", product.price)
        editQuantity = "\(product.quantity)"
        editDescription = product.description
    }

    func cancelEdit() {
        editingProductId = nil
    }

    func saveEdit(for productId: String) {
        guard let idx = myProducts.firstIndex(where: { $0.id == productId }),
              let price = Double(editPrice), price > 0,
              let qty = Int(editQuantity), qty >= 0 else {
            toastMessage = "Invalid price or quantity"
            return
        }
        let name = editName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            toastMessage = "Product name cannot be empty"
            return
        }
        Task {
            do {
                try await marketService.updateProduct(
                    productId: productId,
                    name: name,
                    price: price,
                    quantity: qty,
                    description: editDescription.trimmingCharacters(in: .whitespaces)
                )
                myProducts[idx].name = name
                myProducts[idx].price = price
                myProducts[idx].quantity = qty
                myProducts[idx].description = editDescription.trimmingCharacters(in: .whitespaces)
                editingProductId = nil
                toastMessage = "Product updated"
            } catch {
                toastMessage = "Failed to update: \(error.localizedDescription)"
            }
        }
    }
}
