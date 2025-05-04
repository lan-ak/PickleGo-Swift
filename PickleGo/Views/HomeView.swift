import SwiftUI

struct HomeView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    @State private var showingNewMatch = false
    
    private var nextMatch: Match? {
        matchViewModel.matches
            .filter { $0.status == .scheduled }
            .sorted { $0.date < $1.date }
            .first
    }
    
    private var recentMatches: [Match] {
        Array(matchViewModel.matches
            .filter { $0.status == .completed }
            .sorted { $0.date > $1.date }
            .prefix(3))
    }
    
    private var userId: String? {
        authService.currentUser?.id
    }
    
    private func didWin(match: Match) -> Bool? {
        guard let userId = userId else { return nil }
        let isTeam1 = match.players.prefix(match.players.count/2).contains(userId)
        let isTeam2 = match.players.suffix(match.players.count/2).contains(userId)
        
        let team1Wins = match.scores.filter { $0.team1Score > $0.team2Score }.count
        let team2Wins = match.scores.filter { $0.team2Score > $0.team1Score }.count
        
        if isTeam1 { return team1Wins > team2Wins }
        if isTeam2 { return team2Wins > team1Wins }
        return nil
    }
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 4) {
                        Text("PickleGo")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Text("Welcome back!")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.dark.opacity(0.7))
                    }
                    .padding(.top, 16)
                    
                    // Next Match Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Next Match")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .padding(.horizontal)
                        
                        if let nextMatch = nextMatch {
                            NavigationLink(destination: MatchDetailView(match: nextMatch)) {
                                VStack(spacing: 16) {
                                    // Team 1
                                    Text(nextMatch.players.prefix(nextMatch.players.count/2).map { playerStore.displayName(for: $0) }.joined(separator: " & "))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(PickleGoTheme.dark)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .lineLimit(1)
                                    
                                    // VS Separator
                                    Text("vs")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                        .padding(.vertical, 4)
                                    
                                    // Team 2
                                    Text(nextMatch.players.suffix(nextMatch.players.count/2).map { playerStore.displayName(for: $0) }.joined(separator: " & "))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(PickleGoTheme.dark)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .lineLimit(1)
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                    
                                    // Match Details
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(nextMatch.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            Text(nextMatch.location)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(nextMatch.matchType.rawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(PickleGoTheme.primaryGreen.opacity(0.15))
                                            .foregroundColor(PickleGoTheme.primaryGreen)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(20)
                                .background(PickleGoTheme.card)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                                .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Stats Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Stats")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Text("Coming Soon")
                                .font(.title3)
                                .foregroundColor(PickleGoTheme.dark.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 32)
                        }
                        .padding(20)
                        .background(PickleGoTheme.card)
                        .cornerRadius(PickleGoTheme.cornerRadius)
                        .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
                        .padding(.horizontal)
                    }
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .padding(.horizontal)
                        
                        ForEach(recentMatches) { match in
                            NavigationLink(destination: MatchDetailView(match: match)) {
                                VStack(spacing: 12) {
                                    // Teams
                                    HStack {
                                        Text(match.players.prefix(match.players.count/2).map { playerStore.displayName(for: $0) }.joined(separator: " & "))
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(PickleGoTheme.dark)
                                        
                                        Text("vs")
                                            .font(.subheadline)
                                            .foregroundColor(PickleGoTheme.primaryGreen)
                                            .padding(.horizontal, 4)
                                        
                                        Text(match.players.suffix(match.players.count/2).map { playerStore.displayName(for: $0) }.joined(separator: " & "))
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(PickleGoTheme.dark)
                                    }
                                    
                                    HStack {
                                        Text(match.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        if let won = didWin(match: match) {
                                            Text(won ? "Won" : "Lost")
                                                .font(.headline)
                                                .foregroundColor(won ? PickleGoTheme.primaryGreen : .red)
                                        }
                                    }
                                }
                                .padding()
                                .background(PickleGoTheme.card)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                                .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .sheet(isPresented: $showingNewMatch) {
                MatchCreationView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MatchViewModel())
        .environmentObject(AuthenticationService())
        .environmentObject(PlayerStore())
} 