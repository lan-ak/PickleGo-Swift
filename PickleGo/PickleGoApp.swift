//
//  PickleGoApp.swift
//  PickleGo
//
//  Created by Lanre Akinyemi on 2025-05-03.
//

import SwiftUI

@main
struct PickleGoApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var matchViewModel = MatchViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(matchViewModel)
        }
    }
}
