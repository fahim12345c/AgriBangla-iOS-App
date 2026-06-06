//
//  Coordinator.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import SwiftUI
import Combine

class Coordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    @Published var sheet: Page?
    //@Published var fullScreenCover: FullScreenCover?
    //@Published var fullScreenDismiss: (() -> Void)?
    //@Published var sheetDismiss: (() -> Void)?
    
    func push(_ page: Page) {path.append(page) }
//    func present(sheet: Page, onDismiss: (() -> Void)? = nil) {
//        self.sheet = sheet
//        self.sheetDismiss = onDismiss
//    }
//    func present(fullScreenCover: FullScreenCover, onDismiss: (() -> Void)? = nil) {
//        self.fullScreenCover = fullScreenCover
//        self.fullScreenDismiss = onDismiss
//    }
    func pop() {
        guard !path.isEmpty else {return}
        path.removeLast()
    }
    func popToRoot() {
        guard !path.isEmpty else {return}
        path.removeLast(path.count)
    }
    func resetNavigation() {
        path = NavigationPath()
    }
    func replaceStack(with page: Page) {
        path = NavigationPath()
        path.append(page)
    }
   // func isSheetOpen() -> Bool {sheet != nil}
  //  func dismissSheet() {sheet = nil}
    //func dismissFullScreenCover() {fullScreenCover = nil}
}


extension Coordinator {
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page{
        case .createAccountView(let viewModel) : CreateAccountView(viewModel: viewModel)
        case .loginView(let viewModel): LoginView(viewModel: viewModel)
        case .homeView: MainTabView()
            
        }
    }
        
}
    

//extension Coordinator {
//        @ViewBuilder
//    func build(sheet: Page) -> some View {
//        
//    }
//        
//}
//    
//extension Coordinator {
//        @ViewBuilder
//    func build(fullScreen: FullScreenCover) -> some View {
//        
//    }
//        
//}
    
    
