import Foundation

enum Page {
    case createAccountView(viewModel: CreateAccountViewModel)
    case loginView(viewModel: LoginViewModel)
    case homeView
    case marketCartView(viewModel: MarketViewModel)
    case marketCheckoutView(viewModel: MarketViewModel)
    case marketOrderConfirmation
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
        case .marketCartView: hasher.combine(3)
        case .marketCheckoutView: hasher.combine(4)
        case .marketOrderConfirmation: hasher.combine(5)
        }
    }
    static func == (lhs: Page, rhs: Page) -> Bool {
        switch (lhs, rhs) {
        case (.loginView, .loginView),
            (.homeView, .homeView),
            (.marketOrderConfirmation, .marketOrderConfirmation):
            return true
        case (.createAccountView(let lhsData), .createAccountView(let rhsData)):
            return lhsData.id == rhsData.id
        case (.marketCartView(let lhsData), .marketCartView(let rhsData)),
            (.marketCheckoutView(let lhsData), .marketCheckoutView(let rhsData)):
            return lhsData === rhsData
        default:
            return false
        }
    }
}
