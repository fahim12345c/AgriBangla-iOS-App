import Foundation
import Combine
import FirebaseAuth

@MainActor
final class MarketViewModel: ObservableObject {
    @Published var selectedCategory: MarketProduct.MarketCategory?
    @Published var products: [MarketProduct] = []
    @Published var cartItems: [CartItem] = []
    @Published var userBalance: Double = 0
    @Published var isLoading = false
    @Published var showSellSuccess = false
    @Published var toastMessage: String?
    @Published var currentUserRole: UserRole?

    private let marketService = MarketService.shared
    private let firestoreManager = FirestoreManager.shared

    var cartTotal: Double {
        cartItems.reduce(0) { $0 + ($1.productPrice * Double($1.quantity)) }
    }

    var cartCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var canAffordCart: Bool {
        userBalance >= cartTotal
    }

    func canAffordProduct(_ price: Double) -> Bool {
        userBalance >= price
    }

    // MARK: - User

    func loadCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            if let user = try await firestoreManager.fetchUser(userId: uid) {
                currentUserRole = user.role
                userBalance = user.balance
            } else {
                currentUserRole = .farmer
            }
        } catch {
            print("Failed to load user: \(error)")
            currentUserRole = .farmer
        }
    }

    // MARK: - Products

    func loadProducts() {
        isLoading = true
        Task {
            do {
                products = try await marketService.fetchProducts(category: selectedCategory)
            } catch {
                toastMessage = "Failed to load products"
                print("Fetch products error: \(error)")
            }
            isLoading = false
        }
    }

    func filterCategory(_ category: MarketProduct.MarketCategory?) {
        selectedCategory = category
        loadProducts()
    }

    // MARK: - Cart

    func addToCart(product: MarketProduct) {
        guard product.quantity > 0 else {
            toastMessage = "Sorry, this product is out of stock"
            return
        }
        if let index = cartItems.firstIndex(where: { $0.productID == product.id }) {
            let current = cartItems[index]
            let newQty = current.quantity + 1
            guard newQty <= product.quantity else {
                toastMessage = "Only \(product.quantity) available in stock"
                return
            }
            cartItems[index] = CartItem(
                id: current.id,
                productID: current.productID,
                productName: current.productName,
                productPrice: current.productPrice,
                productIcon: current.productIcon,
                category: current.category,
                quantity: newQty,
                sellerId: current.sellerId,
                sellerName: current.sellerName,
                addedAt: current.addedAt
            )
        } else {
            guard 1 <= product.quantity else {
                toastMessage = "Sorry, this product is out of stock"
                return
            }
            let item = CartItem(
                id: UUID().uuidString,
                productID: product.id,
                productName: product.name,
                productPrice: product.price,
                productIcon: product.iconName,
                category: product.category.rawValue,
                quantity: 1,
                sellerId: product.sellerId,
                sellerName: product.sellerName,
                addedAt: Date()
            )
            cartItems.append(item)
        }
        toastMessage = "\(product.name) added to cart"
    }

    func removeFromCart(cartItemID: String) {
        cartItems.removeAll { $0.id == cartItemID }
    }

    func updateQuantity(cartItemID: String, quantity: Int) {
        guard quantity > 0 else {
            removeFromCart(cartItemID: cartItemID)
            return
        }
        if let index = cartItems.firstIndex(where: { $0.id == cartItemID }) {
            let current = cartItems[index]
            cartItems[index] = CartItem(
                id: current.id,
                productID: current.productID,
                productName: current.productName,
                productPrice: current.productPrice,
                productIcon: current.productIcon,
                category: current.category,
                quantity: quantity,
                sellerId: current.sellerId,
                sellerName: current.sellerName,
                addedAt: current.addedAt
            )
        }
    }

    func clearCart() {
        cartItems = []
        toastMessage = "Cart cleared"
    }

    // MARK: - Balance

    func loadBalance() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Task {
            do {
                userBalance = try await marketService.fetchBalance(userId: uid)
            } catch {
                print("Failed to load balance: \(error)")
            }
        }
    }

    func deposit(amount: Double) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard amount > 0 else {
            toastMessage = "Enter a valid amount"
            return
        }
        Task {
            do {
                try await marketService.addBalance(userId: uid, amount: amount)
                userBalance = try await marketService.fetchBalance(userId: uid)
                toastMessage = "৳\(String(format: "%.0f", amount)) deposited successfully"
            } catch {
                toastMessage = "Deposit failed"
                print("Deposit error: \(error)")
            }
        }
    }

    // MARK: - Sell (Seller only)

    func listProductForSale(name: String, price: Double, quantity: Int, category: MarketProduct.MarketCategory, description: String) {
        guard let uid = Auth.auth().currentUser?.uid,
              let displayName = Auth.auth().currentUser?.displayName else {
            toastMessage = "User not logged in"
            return
        }
        Task {
            do {
                let product = MarketProduct(
                    name: name,
                    price: price,
                    quantity: quantity,
                    category: category,
                    iconName: category.sfSymbol,
                    description: description,
                    sellerId: uid,
                    sellerName: displayName
                )
                try await marketService.addProduct(product)
                showSellSuccess = true
            } catch {
                toastMessage = "Failed to list product: \(error.localizedDescription)"
                print("List product error: \(error)")
            }
        }
    }

    // MARK: - Checkout

    func placeOrder(address: DeliveryAddress) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw MarketError.notLoggedIn
        }
        guard canAffordCart else {
            throw MarketError.insufficientBalance
        }
        guard !cartItems.isEmpty else {
            throw MarketError.emptyCart
        }

        let total = cartTotal
        let items = cartItems
        let displayName = Auth.auth().currentUser?.displayName ?? "Farmer"

        try await marketService.placeOrderAtomic(
            farmerId: uid,
            farmerName: displayName,
            items: items,
            address: address,
            total: total
        )

        userBalance -= total
        clearCart()
        loadProducts()
    }
}
