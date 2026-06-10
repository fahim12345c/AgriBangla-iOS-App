import Foundation

final class MarketService {
    static let shared = MarketService()
    private init() {}

    // MARK: - Balance

    private(set) var userBalance: Double = 0

    func addBalance(amount: Double) {
        userBalance += amount
    }

    func reduceBalance(amount: Double) -> Bool {
        guard userBalance >= amount else { return false }
        userBalance -= amount
        return true
    }

    // MARK: - Products

    private let allProducts: [MarketProduct] = [
        MarketProduct(name: "Rice Seed", nameBN: "ধান বীজ", price: 85.0, quantity: 200, category: .plant, iconName: "leaf.fill", description: "High-yield hybrid rice seeds, suitable for Boro season", descriptionBN: "বোরো মৌসুমের জন্য উচ্চ ফলনশীল হাইব্রিড ধান বীজ"),
        MarketProduct(name: "Tomato Seedling", nameBN: "টমেটো চারা", price: 5.0, quantity: 500, category: .plant, iconName: "leaf.fill", description: "Disease-resistant tomato seedlings per piece", descriptionBN: "প্রতি পিস রোগ-প্রতিরোধী টমেটো চারা"),
        MarketProduct(name: "Mango Sapling", nameBN: "আমের চারা", price: 120.0, quantity: 80, category: .plant, iconName: "leaf.fill", description: "Grafted mango sapling, variety: Himsagar", descriptionBN: "কলম করা আমের চারা, জাত: হিমসাগর"),
        MarketProduct(name: "Potato Seed", nameBN: "আলু বীজ", price: 45.0, quantity: 300, category: .plant, iconName: "leaf.fill", description: "High-grade potato seeds per kg", descriptionBN: "প্রতি কেজি উচ্চমানের আলু বীজ"),
        MarketProduct(name: "Onion Seed", nameBN: "পেঁয়াজ বীজ", price: 95.0, quantity: 250, category: .plant, iconName: "leaf.fill", description: "High-yield onion seeds per kg", descriptionBN: "প্রতি কেজি উচ্চ ফলনশীল পেঁয়াজ বীজ"),
        MarketProduct(name: "Brinjal Seedling", nameBN: "বেগুন চারা", price: 6.0, quantity: 400, category: .plant, iconName: "leaf.fill", description: "Disease-resistant brinjal seedlings per piece", descriptionBN: "প্রতি পিস রোগ-প্রতিরোধী বেগুন চারা"),
        MarketProduct(name: "Chili Seed", nameBN: "মরিচ বীজ", price: 110.0, quantity: 180, category: .plant, iconName: "leaf.fill", description: "Hybrid chili seeds, high yield per kg", descriptionBN: "প্রতি কেজি হাইব্রিড মরিচ বীজ, উচ্চ ফলন"),
        MarketProduct(name: "Mustard Seed", nameBN: "সরিষা বীজ", price: 65.0, quantity: 220, category: .plant, iconName: "leaf.fill", description: "Premium mustard seeds for oil production per kg", descriptionBN: "প্রতি কেজি প্রিমিয়াম সরিষা বীজ"),
        MarketProduct(name: "Lemon Sapling", nameBN: "লেবু চারা", price: 80.0, quantity: 100, category: .plant, iconName: "leaf.fill", description: "Grafted lemon sapling, high-yield variety", descriptionBN: "কলম করা লেবু চারা, উচ্চ ফলনশীল জাত"),
        MarketProduct(name: "Papaya Sapling", nameBN: "পেঁপে চারা", price: 55.0, quantity: 120, category: .plant, iconName: "leaf.fill", description: "Dwarf papaya sapling, fruits within 8 months", descriptionBN: "বামন পেঁপে চারা, ৮ মাসের মধ্যে ফল"),

        MarketProduct(name: "Insecticide", nameBN: "কীটনাশক", price: 350.0, quantity: 100, category: .medicine, iconName: "pills.fill", description: "Broad-spectrum insecticide for rice and vegetables (500ml)", descriptionBN: "ধান ও সবজির জন্য ব্রড-স্পেকট্রাম কীটনাশক (৫০০মি.লি.)"),
        MarketProduct(name: "Fungicide", nameBN: "ছত্রাকনাশক", price: 280.0, quantity: 120, category: .medicine, iconName: "pills.fill", description: "Systemic fungicide for leaf spot and blight (250ml)", descriptionBN: "পাতার দাগ ও ব্লাইটের জন্য সিস্টেমিক ছত্রাকনাশক (২৫০মি.লি.)"),
        MarketProduct(name: "Weedicide", nameBN: "আগাছানাশক", price: 220.0, quantity: 90, category: .medicine, iconName: "pills.fill", description: "Pre-emergence weedicide for rice fields (1L)", descriptionBN: "ধান ক্ষেতের জন্য প্রি-ইমারজেন্স আগাছানাশক (১লি.)"),
        MarketProduct(name: "Ripcord", nameBN: "রিপকর্ড", price: 320.0, quantity: 80, category: .medicine, iconName: "pills.fill", description: "Effective insecticide for vegetable pests (500ml)", descriptionBN: "সবজি পোকামাকড়ের জন্য কার্যকর কীটনাশক (৫০০মি.লি.)"),
        MarketProduct(name: "Vitamin B1", nameBN: "ভিটামিন বি১", price: 150.0, quantity: 200, category: .medicine, iconName: "pills.fill", description: "Plant growth vitamin, strengthens roots (100ml)", descriptionBN: "উদ্ভিদ বৃদ্ধি ভিটামিন, শিকড় মজবুত করে (১০০মি.লি.)"),
        MarketProduct(name: "Growth Hormone", nameBN: "গ্রোথ হরমোন", price: 180.0, quantity: 150, category: .medicine, iconName: "pills.fill", description: "Liquid growth hormone for faster plant development (250ml)", descriptionBN: "দ্রুত উদ্ভিদ বৃদ্ধির জন্য তরল গ্রোথ হরমোন (২৫০মি.লি.)"),
        MarketProduct(name: "Plant Antibiotic", nameBN: "উদ্ভিদ অ্যান্টিবায়োটিক", price: 400.0, quantity: 60, category: .medicine, iconName: "pills.fill", description: "Broad-spectrum antibiotic for bacterial plant diseases (200g)", descriptionBN: "ব্যাকটেরিয়াল উদ্ভিদ রোগের জন্য ব্রড-স্পেকট্রাম অ্যান্টিবায়োটিক (২০০গ্রাম)"),
        MarketProduct(name: "Neem Oil", nameBN: "নিম তেল", price: 190.0, quantity: 110, category: .medicine, iconName: "pills.fill", description: "Organic neem oil pesticide, safe for vegetables (500ml)", descriptionBN: "জৈব নিম তেল কীটনাশক, সবজির জন্য নিরাপদ (৫০০মি.লি.)"),

        MarketProduct(name: "Urea Fertilizer", nameBN: "ইউরিয়া সার", price: 16.0, quantity: 500, category: .fertilizer, iconName: "drop.fill", description: "Granular urea fertilizer per kg", descriptionBN: "প্রতি কেজি দানাদার ইউরিয়া সার"),
        MarketProduct(name: "DAP Fertilizer", nameBN: "ডিএপি সার", price: 22.0, quantity: 400, category: .fertilizer, iconName: "drop.fill", description: "Di-ammonium phosphate fertilizer per kg", descriptionBN: "প্রতি কেজি ডাই-অ্যামোনিয়াম ফসফেট সার"),
        MarketProduct(name: "Potash Fertilizer", nameBN: "পটাশ সার", price: 18.0, quantity: 350, category: .fertilizer, iconName: "drop.fill", description: "Muriate of potash fertilizer per kg", descriptionBN: "প্রতি কেজি মিউরিয়েট অফ পটাশ সার"),
        MarketProduct(name: "Organic Compost", nameBN: "জৈব সার", price: 12.0, quantity: 600, category: .fertilizer, iconName: "drop.fill", description: "Rich organic compost fertilizer per kg", descriptionBN: "প্রতি কেজি সমৃদ্ধ জৈব সার"),
        MarketProduct(name: "TSP Fertilizer", nameBN: "টিএসপি সার", price: 25.0, quantity: 300, category: .fertilizer, iconName: "drop.fill", description: "Triple super phosphate fertilizer per kg", descriptionBN: "প্রতি কেজি ট্রিপল সুপার ফসফেট সার"),
        MarketProduct(name: "Gypsum", nameBN: "জিপসাম", price: 14.0, quantity: 280, category: .fertilizer, iconName: "drop.fill", description: "Gypsum fertilizer for soil sulfur and calcium per kg", descriptionBN: "প্রতি কেজি মাটির সালফার ও ক্যালসিয়ামের জন্য জিপসাম সার"),
        MarketProduct(name: "Zinc Fertilizer", nameBN: "জিংক সার", price: 90.0, quantity: 160, category: .fertilizer, iconName: "drop.fill", description: "Zinc sulfate fertilizer for rice per kg", descriptionBN: "প্রতি কেজি ধানের জন্য জিংক সালফেট সার"),
        MarketProduct(name: "Boron Fertilizer", nameBN: "বোরন সার", price: 85.0, quantity: 140, category: .fertilizer, iconName: "drop.fill", description: "Boron fertilizer for better fruiting per kg", descriptionBN: "প্রতি কেজি ভালো ফলনের জন্য বোরন সার"),

        MarketProduct(name: "Knapsack Sprayer", nameBN: "ন্যাপস্যাক স্প্রেয়ার", price: 850.0, quantity: 30, category: .equipment, iconName: "wrench.adjustable.fill", description: "16L manual knapsack sprayer for pesticide application", descriptionBN: "কীটনাশক প্রয়োগের জন্য ১৬লি. ম্যানুয়াল ন্যাপস্যাক স্প্রেয়ার"),
        MarketProduct(name: "Hand Shovel", nameBN: "কোদাল", price: 250.0, quantity: 60, category: .equipment, iconName: "wrench.adjustable.fill", description: "Carbon steel hand shovel with wooden handle", descriptionBN: "কাঠের হাতল সহ কার্বন স্টিলের কোদাল"),
        MarketProduct(name: "Irrigation Pipe", nameBN: "সেচ পাইপ", price: 45.0, quantity: 150, category: .equipment, iconName: "wrench.adjustable.fill", description: "Flexible PVC irrigation pipe per meter (1 inch dia)", descriptionBN: "প্রতি মিটার ফ্লেক্সিবল পিভিসি সেচ পাইপ (১ ইঞ্চি)"),
        MarketProduct(name: "Power Tiller Blade", nameBN: "পাওয়ার টিলার ব্লেড", price: 650.0, quantity: 40, category: .equipment, iconName: "wrench.adjustable.fill", description: "Spare blade set for power tiller (set of 4)", descriptionBN: "পাওয়ার টিলারের জন্য অতিরিক্ত ব্লেড সেট (৪টি)"),
        MarketProduct(name: "Sickle", nameBN: "কাস্তে", price: 180.0, quantity: 90, category: .equipment, iconName: "wrench.adjustable.fill", description: "Carbon steel sickle for harvesting crops", descriptionBN: "ফসল কাটার জন্য কার্বন স্টিলের কাস্তে"),
        MarketProduct(name: "Water Pump", nameBN: "জল পাম্প", price: 3200.0, quantity: 15, category: .equipment, iconName: "wrench.adjustable.fill", description: "1HP electric water pump for irrigation", descriptionBN: "সেচের জন্য ১এইচপি বৈদ্যুতিক জল পাম্প"),
        MarketProduct(name: "Plough", nameBN: "লাঙ্গল", price: 1200.0, quantity: 20, category: .equipment, iconName: "wrench.adjustable.fill", description: "Heavy-duty iron plough for tractor", descriptionBN: "ট্রাক্টরের জন্য ভারী লোহার লাঙ্গল"),
        MarketProduct(name: "Fertilizer Spreader", nameBN: "সার ছড়ানোর যন্ত্র", price: 450.0, quantity: 35, category: .equipment, iconName: "wrench.adjustable.fill", description: "Hand-held rotary fertilizer spreader", descriptionBN: "হাতে ধরা রোটারি সার ছড়ানোর যন্ত্র"),
    ]

    func fetchProducts(category: MarketProduct.MarketCategory? = nil) -> [MarketProduct] {
        let filtered = category.map { cat in allProducts.filter { $0.category == cat } } ?? allProducts
        return filtered.filter { $0.quantity > 0 }
    }

    // MARK: - Cart

    private var cartItems: [CartItem] = []
    private var nextCartID = 1

    func addToCart(product: MarketProduct) {
        if let index = cartItems.firstIndex(where: { $0.productID == product.id }) {
            let current = cartItems[index]
            cartItems[index] = CartItem(
                id: current.id,
                productID: current.productID,
                productName: current.productName,
                productNameBN: current.productNameBN,
                productPrice: current.productPrice,
                productIcon: current.productIcon,
                category: current.category,
                quantity: current.quantity + 1,
                addedAt: current.addedAt
            )
        } else {
            let item = CartItem(
                id: "cart_\(nextCartID)",
                productID: product.id,
                productName: product.name,
                productNameBN: product.nameBN,
                productPrice: product.price,
                productIcon: product.iconName,
                category: product.category.rawValue,
                quantity: 1,
                addedAt: Date()
            )
            nextCartID += 1
            cartItems.append(item)
        }
    }

    func fetchCart() -> [CartItem] {
        cartItems
    }

    func removeFromCart(cartItemID: String) {
        cartItems.removeAll { $0.id == cartItemID }
    }

    func updateCartQuantity(cartItemID: String, quantity: Int) {
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
                productNameBN: current.productNameBN,
                productPrice: current.productPrice,
                productIcon: current.productIcon,
                category: current.category,
                quantity: quantity,
                addedAt: current.addedAt
            )
        }
    }

    func clearCart() {
        cartItems.removeAll()
    }

    // MARK: - Crop Listings (Sell)

    private(set) var cropListings: [CropListing] = []
    private var nextListingID = 1

    func createCropListing(cropName: String, cropNameBN: String, price: Double, quantity: String, quantityBN: String, description: String, descriptionBN: String, imageData: Data?) -> CropListing {
        let listing = CropListing(
            id: "listing_\(nextListingID)",
            cropName: cropName,
            cropNameBN: cropNameBN,
            price: price,
            quantity: quantity,
            quantityBN: quantityBN,
            description: description,
            descriptionBN: descriptionBN,
            imageData: imageData
        )
        nextListingID += 1
        cropListings.append(listing)
        return listing
    }

}

struct CropListing: Identifiable {
    let id: String
    let cropName: String
    let cropNameBN: String
    let price: Double
    let quantity: String
    let quantityBN: String
    let description: String
    let descriptionBN: String
    let imageData: Data?
}
