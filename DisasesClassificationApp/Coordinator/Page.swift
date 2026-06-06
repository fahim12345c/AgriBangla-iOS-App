//
//  Sheet.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import Foundation

enum Page {
    case  createAccountView(viewModel: CreateAccountViewModel)
    case  loginView(viewModel: LoginViewModel)
    case  homeView
}

extension Page: Identifiable {
    var id: Self { self }
}
extension Page: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .loginView: hasher.combine(0)
        case .homeView: hasher.combine(1)
        case .createAccountView: hasher.combine(2)
        }
    }
    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
        case (.loginView,.loginView),
            (.homeView, .homeView):
            return true
        case (.createAccountView(let lhsData), .createAccountView(let rhsData)): return lhsData.id  == rhsData.id
        default:
            return false
        }
    }
}
