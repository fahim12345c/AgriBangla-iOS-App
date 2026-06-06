//
//  UserModel.swift
//  DisasesClassificationApp
//

import Foundation

struct UserModel: Codable, Identifiable {
    let id: String
    let email: String
    let createdAt: Date
}
