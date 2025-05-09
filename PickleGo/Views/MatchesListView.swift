import SwiftUI

struct MatchesListView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    @State private var showingNewMatch = false
    @State private var selectedTab: MatchTab = .upcoming
    @State private var matchToComplete: Match? = nil
    
    enum MatchTab: String, CaseIterable, Identifiable {
        case upcoming = "Upcoming"
        case won = "Won"
        case lost = "Lost"
        var id: String { rawValue }
    }
    
    private var userId: String? {
        authService.currentUser?.id
    }
    
    private var allMatches: [Match] {
        matchViewModel.matches
            .sorted { $0.date > $1.date }
    }
    
    private var upcomingMatches: [Match] {
        matchViewModel.matches
            .filter { match in
                guard let userId = userId else { return false }
                return match.status == .scheduled && match.players.contains(userId)
            }
            .sorted { $0.date < $1.date }
    }
    
    private var completedMatches: [Match] {
        matchViewModel.matches
            .filter { match in
                guard let userId = userId else { return false }
                return match.status == .completed && match.players.contains(userId)
            }
            .sorted { $0.date > $1.date }
    }
    
    private func isUserInTeam1(of match: Match) -> Bool {
        guard let userId = userId else { return false }
        return match.players.prefix(match.players.count/2).contains(userId)
    }
    
    private func isUserInTeam2(of match: Match) -> Bool {
        guard let userId = userId else { return false }
        return match.players.suffix(match.players.count/2).contains(userId)
    }
    
    private func team1Wins(in match: Match) -> Int {
        match.scores.filter { $0.team1Score > $0.team2Score }.count
    }
    
    private func team2Wins(in match: Match) -> Int {
        match.scores.filter { $0.team2Score > $0.team1Score }.count
    }
    
    private var wonMatches: [Match] {
        completedMatches.filter { match in
            let isTeam1 = isUserInTeam1(of: match)
            let isTeam2 = isUserInTeam2(of: match)
            let team1Wins = team1Wins(in: match)
            let team2Wins = team2Wins(in: match)
            
            if isTeam1 && team1Wins > team2Wins { return true }
            if isTeam2 && team2Wins > team1Wins { return true }
            return false
        }
    }
    
    private var lostMatches: [Match] {
        completedMatches.filter { match in
            let isTeam1 = isUserInTeam1(of: match)
            let isTeam2 = isUserInTeam2(of: match)
            let team1Wins = team1Wins(in: match)
            let team2Wins = team2Wins(in: match)
            
            if isTeam1 && team1Wins < team2Wins { return true }
            if isTeam2 && team2Wins < team1Wins { return true }
            return false
        }
    }
    
    private var filteredMatches: [Match] {
        switch selectedTab {
        case .upcoming: return upcomingMatches
        case .won: return wonMatches
        case .lost: return lostMatches
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                PickleGoTheme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Match View", selection: $selectedTab) {
                        ForEach(MatchTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    ScrollView {
                        VStack(spacing: 16) {
                            if filteredMatches.isEmpty {
                                Text("No matches found.")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredMatches) { match in
                                    NavigationLink(destination: MatchDetailView(match: match)) {
                                        MatchRowCard(match: match)
                                            .padding(.horizontal, 16)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        if match.status == .scheduled {
                                            Button {
                                                matchToComplete = match
                                            } label: {
                                                Label("Complete", systemImage: "checkmark.circle")
                                            }
                                            .tint(PickleGoTheme.primaryGreen)
                                        }
                                        Button(role: .destructive) {
                                            Task {
                                                try? await matchViewModel.deleteMatch(match)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    }
                }
                .sheet(isPresented: $showingNewMatch) {
                    MatchCreationView()
                }
                .sheet(item: $matchToComplete) { match in
                    MatchCompletionView(match: match)
                        .onDisappear {
                            matchToComplete = nil
                        }
                }
                .refreshable {
                    try? await matchViewModel.fetchMatches()
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showingNewMatch = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 56, height: 56)
                                    .foregroundColor(PickleGoTheme.primaryYellow)
                                    .shadow(radius: 6)
                            }
                            .padding()
                        }
                    }
                )
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MatchRowCard: View {
    let match: Match
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    
    private func formattedName(_ name: String) -> String {
        let parts = name.split(separator: " ")
        guard let first = parts.first else { return name }
        if parts.count > 1, let last = parts.last, let initial = last.first {
            return "\(first) \(initial)"
        } else {
            return String(first)
        }
    }
    
    private var teamDisplay: (team1: String, team2: String) {
        let names = match.players.map { formattedName(playerStore.displayName(for: $0)) }
        switch match.matchType {
        case .singles:
            if names.count == 2 {
                return (names[0], names[1])
            }
            return (names.joined(separator: ", "), "")
        case .doubles:
            if names.count == 4 {
                let team1 = "\(names[0]) & \(names[1])"
                let team2 = "\(names[2]) & \(names[3])"
                return (team1, team2)
            }
            return (names.joined(separator: ", "), "")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Match Type Indicator
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: match.matchType == .singles ? "person.fill" : "person.2.fill")
                        .font(.caption)
                    Text(match.matchType.rawValue)
                        .font(.caption)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(PickleGoTheme.primaryGreen.opacity(0.15))
                .foregroundColor(PickleGoTheme.primaryGreen)
                .cornerRadius(8)
                
                if match.matchType == .doubles {
                    HStack(spacing: 4) {
                        Image(systemName: match.partnerSelection == .fixed ? "arrow.left.arrow.right.circle.fill" : "arrow.triangle.2.circlepath.circle.fill")
                            .font(.caption)
                        Text(match.partnerSelection.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(PickleGoTheme.primaryYellow.opacity(0.15))
                    .foregroundColor(PickleGoTheme.primaryYellow)
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            
            // Team 1
            Text(teamDisplay.team1)
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
            Text(teamDisplay.team2)
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
                    Text(match.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Text(match.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(PickleGoTheme.card)
        .cornerRadius(PickleGoTheme.cornerRadius)
        .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
        .padding(.vertical, 8)
    }
}

#Preview {
    MatchesListView()
        .environmentObject(MatchViewModel())
        .environmentObject(AuthenticationService())
        .environmentObject(PlayerStore())
} 
