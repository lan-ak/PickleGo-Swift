import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    @State private var showingNewMatch = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            MatchesListView()
                .tabItem {
                    Label("Matches", systemImage: "list.bullet")
                }
                .tag(1)
            
            // Empty view for the center + button
            Color.clear
                .tabItem {
                    Label("New Match", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            Text("Stats")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 2 {
                showingNewMatch = true
                selectedTab = 1 // Return to Matches tab
            }
        }
        .sheet(isPresented: $showingNewMatch) {
            MatchCreationView()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(MatchViewModel())
} 