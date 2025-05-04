//
//  ContentView.swift
//  PickleGo
//
//  Created by Lanre Akinyemi on 2025-05-03.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var matchViewModel = MatchViewModel()
    @StateObject private var playerStore = PlayerStore()
    
    var body: some View {
        MainTabView()
            .environmentObject(authService)
            .environmentObject(matchViewModel)
            .environmentObject(playerStore)
            .onAppear {
                let testUser = User(
                    id: "test@test.com",
                    username: "Test User",
                    email: "test@test.com",
                    profileImageURL: nil,
                    friends: [],
                    matches: []
                )
                authService.isAuthenticated = true
                authService.currentUser = testUser
                
                // Add test user to player store
                let testPlayer = Player.fromUser(testUser)
                playerStore.addIfNeeded(testPlayer)
            }
    }
}

#Preview {
    ContentView()
}
