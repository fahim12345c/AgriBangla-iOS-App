import Foundation
import FirebaseFirestore

final class MarketReviewService {
    static let shared = MarketReviewService()
    private let db = Firestore.firestore()
    private init() {}

    func addReview(productId: String, farmerId: String, farmerName: String, rating: Int, comment: String) async throws {
        try await db.collection("reviews").addDocument(data: [
            "productId": productId,
            "farmerId": farmerId,
            "farmerName": farmerName,
            "rating": rating,
            "comment": comment,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    func fetchReviews(for productId: String) async throws -> [ProductReview] {
        let snapshot = try await db.collection("reviews")
            .whereField("productId", isEqualTo: productId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let pid = data["productId"] as? String,
                  let fid = data["farmerId"] as? String,
                  let fn = data["farmerName"] as? String,
                  let r = data["rating"] as? Int,
                  let c = data["comment"] as? String else { return nil }
            return ProductReview(
                id: doc.documentID,
                productId: pid,
                farmerId: fid,
                farmerName: fn,
                rating: r,
                comment: c,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }

    func fetchAverageRating(for productId: String) async throws -> Double {
        let reviews = try await fetchReviews(for: productId)
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }

    func fetchAllReviewsForSeller(sellerId: String) async throws -> [ProductReview] {
        let products = try await MarketService.shared.fetchProducts()
        let sellerProductIds = products.filter { $0.sellerId == sellerId }.map { $0.id }
        guard !sellerProductIds.isEmpty else { return [] }
        let snapshot = try await db.collection("reviews")
            .whereField("productId", in: sellerProductIds)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard let pid = data["productId"] as? String,
                  let fid = data["farmerId"] as? String,
                  let fn = data["farmerName"] as? String,
                  let r = data["rating"] as? Int,
                  let c = data["comment"] as? String else { return nil }
            return ProductReview(
                id: doc.documentID,
                productId: pid,
                farmerId: fid,
                farmerName: fn,
                rating: r,
                comment: c,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
}
