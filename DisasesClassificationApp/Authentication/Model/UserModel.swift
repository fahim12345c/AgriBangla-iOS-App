//
//  UserModel.swift
//  DisasesClassificationApp
//

import Foundation

struct UserModel: Codable, Identifiable {
    let id: String
    let email: String
    var firstName: String?
    var lastName: String?
    var profileImageURL: String?
    let createdAt: Date
}
