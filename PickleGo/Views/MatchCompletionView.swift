import SwiftUI

struct SetScore: Identifiable {
    let id = UUID()
    var team1: Int
    var team2: Int
}

struct MatchCompletionView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var playerStore: PlayerStore
    @Environment(\.dismiss) var dismiss
    let match: Match
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingSaveConfirmation = false
    @State private var isSaving = false
    
    @State private var currentSet = 1
    @State private var team1Scores: [Int] = []
    @State private var team2Scores: [Int] = []
    @State private var editingSet: Int? = nil
    @State private var gamesPerSet: Int = 2
    @State private var sets: [SetScore] = []
    
    private var userId: String? {
        authService.currentUser?.id
    }
    
    private var isTeam1: Bool {
        guard let userId = userId else { return false }
        return match.players.prefix(match.players.count/2).contains(userId)
    }
    
    private var isTeam2: Bool {
        guard let userId = userId else { return false }
        return match.players.suffix(match.players.count/2).contains(userId)
    }
    
    private var matchResult: String {
        if team1Wins > team2Wins {
            return isTeam1 ? "You Won!" : "You Lost"
        } else if team2Wins > team1Wins {
            return isTeam2 ? "You Won!" : "You Lost"
        }
        return "Match Tied"
    }
    
    private var isComplete: Bool {
        currentSet > match.numberOfSets
    }
    
    private var team1Wins: Int {
        zip(team1Scores, team2Scores).filter { $0.0 > $0.1 }.count
    }
    
    private var team2Wins: Int {
        zip(team1Scores, team2Scores).filter { $0.1 > $0.0 }.count
    }
    
    private var allScoresEntered: Bool {
        sets.allSatisfy { set in
            set.team1 > 0 || set.team2 > 0
        }
    }
    
    private var canComplete: Bool {
        allScoresEntered
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Team Info Card
                    VStack(spacing: 8) {
                        Text(teamDisplay)
                            .font(.title2).bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("First to \(match.pointsToWin) points per set\nBest of \(match.numberOfSets) sets")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius * 1.2)
                    .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
                    .padding(.horizontal)

                    // Set score entry for all sets
                    ForEach(0..<sets.count, id: \.self) { setIndex in
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Set \(setIndex+1)")
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                Spacer()
                                Button(action: { saveSetScore(setIndex) }) {
                                    Label("Save", systemImage: "square.and.arrow.down")
                                        .font(.subheadline)
                                        .foregroundColor(PickleGoTheme.primaryGreen)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(PickleGoTheme.card)
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack(spacing: 16) {
                                Text(team1Display)
                                    .font(.body)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                Spacer()
                                Menu {
                                    ForEach(0...match.pointsToWin, id: \.self) { n in
                                        Button("\(n)") { sets[setIndex].team1 = n }
                                    }
                                } label: {
                                    Text("\(sets[setIndex].team1)")
                                        .frame(width: 44)
                                        .padding(6)
                                        .background(PickleGoTheme.background)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(PickleGoTheme.primaryGreen.opacity(0.2)))
                                }
                                TextField("Score", value: $sets[setIndex].team1, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .frame(width: 44)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack(spacing: 16) {
                                Text(team2Display)
                                    .font(.body)
                                    .foregroundColor(PickleGoTheme.accentYellow)
                                Spacer()
                                Menu {
                                    ForEach(0...match.pointsToWin, id: \.self) { n in
                                        Button("\(n)") { sets[setIndex].team2 = n }
                                    }
                                } label: {
                                    Text("\(sets[setIndex].team2)")
                                        .frame(width: 44)
                                        .padding(6)
                                        .background(PickleGoTheme.background)
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(PickleGoTheme.primaryGreen.opacity(0.2)))
                                }
                                TextField("Score", value: $sets[setIndex].team2, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .frame(width: 44)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            // Show set winner
                            if sets[setIndex].team1 > sets[setIndex].team2 {
                                Text("Set Winner: \(team1Display)")
                                    .foregroundColor(PickleGoTheme.primaryGreen).bold()
                            } else if sets[setIndex].team2 > sets[setIndex].team1 {
                                Text("Set Winner: \(team2Display)")
                                    .foregroundColor(PickleGoTheme.accentYellow).bold()
                            } else if sets[setIndex].team1 > 0 || sets[setIndex].team2 > 0 {
                                Text("Set Winner: Tied").foregroundColor(.orange)
                            }
                        }
                        .padding(20)
                        .background(PickleGoTheme.card)
                        .cornerRadius(PickleGoTheme.cornerRadius * 1.2)
                        .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
                        .padding(.horizontal)
                    }

                    // Show match summary
                    let team1SetWins = sets.filter { $0.team1 > $0.team2 }.count
                    let team2SetWins = sets.filter { $0.team2 > $0.team1 }.count
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Score:")
                            .font(.headline)
                            .foregroundColor(PickleGoTheme.primaryGreen)
                        Text("\(team1SetWins) - \(team2SetWins)")
                            .font(.title)
                            .bold()
                            .foregroundColor(PickleGoTheme.dark)
                    }
                    .padding(20)
                    .background(PickleGoTheme.card)
                    .cornerRadius(PickleGoTheme.cornerRadius * 1.2)
                    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                    .padding(.horizontal)

                    // Complete button
                    if allScoresEntered {
                        Button(action: completeMatch) {
                            Label("Complete Match", systemImage: "checkmark.circle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PickleGoTheme.primaryGreen)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 32)
            }
            .background(PickleGoTheme.background)
            .navigationTitle("Enter Match Scores")
            .navigationBarItems(leading: Button("Done") {
                dismiss()
            })
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Save Set Score", isPresented: $showingSaveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Save", role: .none) { saveProgress() }
            } message: {
                Text("Would you like to save this set's score?")
            }
            .onAppear {
                if team1Scores.count != match.numberOfSets {
                    team1Scores = Array(repeating: 0, count: match.numberOfSets)
                }
                if team2Scores.count != match.numberOfSets {
                    team2Scores = Array(repeating: 0, count: match.numberOfSets)
                }
                if sets.isEmpty {
                    // Initialize sets with saved scores if they exist
                    if !match.scores.isEmpty {
                        sets = match.scores.map { score in
                            SetScore(team1: score.team1Score, team2: score.team2Score)
                        }
                    } else {
                        sets = (0..<match.numberOfSets).map { _ in SetScore(team1: 0, team2: 0) }
                    }
                }
            }
        }
    }
    
    private var isSetComplete: Bool {
        guard team1Scores.indices.contains(currentSet-1),
              team2Scores.indices.contains(currentSet-1) else {
            return false
        }
        let team1Score = team1Scores[currentSet-1]
        let team2Score = team2Scores[currentSet-1]
        return (team1Score >= match.pointsToWin || team2Score >= match.pointsToWin) &&
               abs(team1Score - team2Score) >= 2
    }
    
    private func nextSet() {
        if isSetComplete {
            currentSet += 1
            team1Scores.append(0)
            team2Scores.append(0)
        }
    }
    
    private func saveSetScore(_ setIndex: Int) {
        showingSaveConfirmation = true
    }
    
    private func saveProgress() {
        isSaving = true
        Task {
            do {
                var updatedMatch = match
                updatedMatch.scores = sets.enumerated().map { index, set in
                    Match.Score(team1Score: set.team1, team2Score: set.team2, gameNumber: index + 1)
                }
                try await matchViewModel.updateMatch(updatedMatch)
                isSaving = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
                isSaving = false
            }
        }
    }
    
    private func completeMatch() {
        isSaving = true
        Task {
            do {
                var updatedMatch = match
                updatedMatch.status = .completed
                updatedMatch.scores = sets.enumerated().map { index, set in
                    Match.Score(team1Score: set.team1, team2Score: set.team2, gameNumber: index + 1)
                }
                try await matchViewModel.updateMatch(updatedMatch)
                isSaving = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
                isSaving = false
            }
        }
    }
    
    // Helper for team display
    private var teamDisplay: String {
        let names = match.players.map { playerName(for: $0) }
        switch match.matchType {
        case .singles:
            if names.count == 2 {
                return "\(names[0]) vs \(names[1])"
            }
            return names.joined(separator: ", ")
        case .doubles:
            if names.count == 4 {
                let team1 = "\(names[0]) & \(names[1])"
                let team2 = "\(names[2]) & \(names[3])"
                return "\(team1) vs \(team2)"
            }
            return names.joined(separator: ", ")
        }
    }
    
    private var team1Display: String {
        let names = match.players.map { playerName(for: $0) }
        switch match.matchType {
        case .singles:
            return names.count > 0 ? names[0] : "Team 1"
        case .doubles:
            return names.count > 1 ? "\(names[0]) & \(names[1])" : "Team 1"
        }
    }
    private var team2Display: String {
        let names = match.players.map { playerName(for: $0) }
        switch match.matchType {
        case .singles:
            return names.count > 1 ? names[1] : "Team 2"
        case .doubles:
            return names.count > 3 ? "\(names[2]) & \(names[3])" : "Team 2"
        }
    }
    
    private func playerName(for id: String) -> String {
        playerStore.displayName(for: id)
    }
}

#Preview {
    MatchCompletionView(match: Match(
        id: UUID().uuidString,
        date: Date(),
        location: "Central Park Courts",
        locationCoordinate: nil,
        matchType: .doubles,
        pointsToWin: 15,
        numberOfSets: 3,
        players: ["Player 1", "Player 2", "Player 3", "Player 4"],
        scores: [],
        status: .scheduled,
        notes: nil,
        isPublicFacility: false,
        partnerSelection: .fixed
    ))
    .environmentObject(MatchViewModel())
    .environmentObject(PlayerStore())
    .environmentObject(AuthenticationService())
} 