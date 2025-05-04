import SwiftUI

struct HomeView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
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
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    PickleGoLogoHeader(subtitle: "Welcome! Schedule and track your pickleball matches.")
                    // Next Match Card
                    if let nextMatch = nextMatch {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Next Match")
                                .font(.headline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(nextMatch.players.joined(separator: " vs "))
                                    .font(.title2)
                                    .bold()
                                HStack {
                                    Image(systemName: "calendar")
                                    Text(nextMatch.date.formatted(date: .abbreviated, time: .shortened))
                                }
                                .foregroundColor(.secondary)
                                HStack {
                                    Image(systemName: "mappin")
                                    Text(nextMatch.location)
                                }
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(PickleGoTheme.card)
                            .cornerRadius(PickleGoTheme.cornerRadius)
                            .shadow(color: PickleGoTheme.shadow, radius: 8, y: 4)
                        }
                        .padding(.horizontal)
                    }
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "New Match",
                                icon: "plus.circle.fill",
                                color: PickleGoTheme.accentYellow
                            ) {
                                showingNewMatch = true
                            }
                            QuickActionButton(
                                title: "Find Players",
                                icon: "person.2.fill",
                                color: PickleGoTheme.primaryGreen
                            ) {
                                // TODO: Implement find players
                            }
                            QuickActionButton(
                                title: "Locations",
                                icon: "mappin.circle.fill",
                                color: .orange
                            ) {
                                // TODO: Implement locations
                            }
                        }
                    }
                    .padding(.horizontal)
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        ForEach(recentMatches) { match in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(match.players.joined(separator: " vs "))
                                        .font(.subheadline)
                                        .bold()
                                    Text(match.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if let lastScore = match.scores.last {
                                    Text("\(lastScore.team1Score) - \(lastScore.team2Score)")
                                        .font(.headline)
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
                .padding(.vertical)
            }
            .sheet(isPresented: $showingNewMatch) {
                MatchCreationView()
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(PickleGoTheme.card)
            .cornerRadius(PickleGoTheme.cornerRadius)
            .shadow(color: PickleGoTheme.shadow, radius: 2, y: 1)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(MatchViewModel())
} 