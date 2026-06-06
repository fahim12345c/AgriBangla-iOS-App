//
//  DisasesClassificationAppApp.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct DiseasesClassificationAppApp: App {
    
    init() {
            FirebaseApp.configure()   
    }
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .onOpenURL { url in
                                GIDSignIn.sharedInstance.handle(url)
                }

        }
    }
}
