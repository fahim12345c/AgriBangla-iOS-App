import Foundation

enum UserRole: String, Codable, CaseIterable {
    case farmer
    case seller
}

struct UserModel: Codable, Identifiable {
    let id: String
    let email: String
    var firstName: String?
    var lastName: String?
    var profileImageURL: String?
    var dateOfBirth: Date?
    var role: UserRole?
    var balance: Double
    let createdAt: Date

    init(id: String, email: String, firstName: String? = nil, lastName: String? = nil, profileImageURL: String? = nil, dateOfBirth: Date? = nil, role: UserRole? = nil, balance: Double = 0, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageURL = profileImageURL
        self.dateOfBirth = dateOfBirth
        self.role = role
        self.balance = balance
        self.createdAt = createdAt
    }
}
