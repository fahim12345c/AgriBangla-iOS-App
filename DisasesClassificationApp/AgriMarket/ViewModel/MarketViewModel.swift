import Foundation
import Combine

@MainActor
final class MarketViewModel: ObservableObject {
    @Published var selectedCategory: MarketProduct.MarketCategory?
    @Published var products: [MarketProduct] = []
    @Published var cartItems: [CartItem] = []
    @Published var userBalance: Double = 0
    @Published var isLoading = false
    @Published var showSellSuccess = false
    @Published var toastMessage: String?
    @Published var cropListings: [CropListing] = []

    private let marketService = MarketService.shared

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

    // MARK: - Products

    func loadProducts() {
        isLoading = true
        products = marketService.fetchProducts(category: selectedCategory)
        isLoading = false
    }

    func filterCategory(_ category: MarketProduct.MarketCategory?) {
        selectedCategory = category
        isLoading = true
        products = marketService.fetchProducts(category: selectedCategory)
        isLoading = false
    }

    // MARK: - Cart

    func addToCart(product: MarketProduct) {
        guard product.quantity > 0 else {
            toastMessage = "Sorry, this product is out of stock"
            return
        }
        marketService.addToCart(product: product)
        toastMessage = "\(product.name) added to cart"
        loadCart()
    }

    func removeFromCart(cartItemID: String) {
        marketService.removeFromCart(cartItemID: cartItemID)
        loadCart()
    }

    func updateQuantity(cartItemID: String, quantity: Int) {
        marketService.updateCartQuantity(cartItemID: cartItemID, quantity: quantity)
        loadCart()
    }

    func loadCart() {
        cartItems = marketService.fetchCart()
    }

    func clearCart() {
        marketService.clearCart()
        cartItems = []
        toastMessage = "Cart cleared"
    }

    // MARK: - Balance

    func loadBalance() {
        userBalance = marketService.userBalance
    }

    func deposit(amount: Double) {
        guard amount > 0 else {
            toastMessage = "Enter a valid amount"
            return
        }
        marketService.addBalance(amount: amount)
        userBalance = marketService.userBalance
        toastMessage = "৳\(String(format: "%.0f", amount)) deposited successfully"
    }

    // MARK: - Sell

    func listCropForSale(cropName: String, cropNameBN: String, price: Double, quantity: String, quantityBN: String, description: String, descriptionBN: String, imageData: Data?) {
        let listing = marketService.createCropListing(
            cropName: cropName,
            cropNameBN: cropNameBN,
            price: price,
            quantity: quantity,
            quantityBN: quantityBN,
            description: description,
            descriptionBN: descriptionBN,
            imageData: imageData
        )
        cropListings = marketService.cropListings
        marketService.addBalance(amount: price)
        userBalance = marketService.userBalance
        showSellSuccess = true
    }

    // MARK: - Checkout

    func placeOrder(address: DeliveryAddress) {
        guard canAffordCart else {
            toastMessage = "Insufficient balance to place order"
            return
        }
        guard !cartItems.isEmpty else {
            toastMessage = "Cart is empty"
            return
        }
        let total = cartTotal
        _ = marketService.reduceBalance(amount: total)
        userBalance = marketService.userBalance
        marketService.clearCart()
        cartItems = []
        loadProducts()
    }
}
