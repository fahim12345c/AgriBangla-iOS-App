import SwiftUI
import Combine

class Coordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Page?
    
    func push(_ page: Page) { path.append(page) }
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }
    func resetNavigation() {
        path = NavigationPath()
    }
    func replaceStack(with page: Page) {
        path = NavigationPath()
        path.append(page)
    }
}

extension Coordinator {
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .createAccountView(let viewModel):
            CreateAccountView(viewModel: viewModel)
        case .loginView(let viewModel):
            LoginView(viewModel: viewModel)
        case .homeView:
            MainTabView()
        case .marketCartView(let viewModel):
            MarketCartView(vm: viewModel)
        case .marketCheckoutView(let viewModel):
            MarketCheckoutView(vm: viewModel)
        case .marketOrderConfirmation:
            MarketOrderConfirmationView()
        }
    }
}
