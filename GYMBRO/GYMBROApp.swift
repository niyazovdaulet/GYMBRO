//
//  GYMBROApp.swift
//  GYMBRO
//
//  Created by Daulet on 03/08/2025.
//

import SwiftUI
import Firebase

@main
struct GYMBROApp: App {
    @StateObject private var authService = FirebaseAuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .preferredColorScheme(.dark)
                    .background(Color.undergroundPrimary)
            } else {
                WelcomeView()
                    .environmentObject(authService)
                    .preferredColorScheme(.dark)
                    .background(Color.undergroundPrimary)
            }
        }
    }
}
