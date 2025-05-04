import SwiftUI
import MapKit

struct MatchDetailView: View {
    @EnvironmentObject var matchViewModel: MatchViewModel
    @EnvironmentObject var playerStore: PlayerStore
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.dismiss) var dismiss
    let match: Match
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingCompletion = false
    @State private var showingDeleteConfirmation = false
    
    private var playerNames: [String] {
        match.players.map { playerStore.displayName(for: $0) }
    }
    
    private var teamDisplay: String {
        let names = match.players.map { playerStore.displayName(for: $0) }
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
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        // Match Status Banner
                        if match.status == .completed, let userId = authService.currentUser?.id {
                            let isTeam1 = match.players.prefix(match.players.count/2).contains(userId)
                            let isTeam2 = match.players.suffix(match.players.count/2).contains(userId)
                            
                            let team1Wins = match.scores.filter { $0.team1Score > $0.team2Score }.count
                            let team2Wins = match.scores.filter { $0.team2Score > $0.team1Score }.count
                            
                            let didWin: Bool = {
                                if isTeam1 { return team1Wins > team2Wins }
                                if isTeam2 { return team2Wins > team1Wins }
                                return false
                            }()
                            
                            HStack(spacing: 12) {
                                Image(systemName: didWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title2)
                                Text(didWin ? "You Won!" : "You Lost")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(didWin ? PickleGoTheme.primaryGreen : Color.red)
                            .cornerRadius(PickleGoTheme.cornerRadius)
                            .padding(.horizontal)
                        }
                        
                        // Match Title
                        VStack(spacing: 12) {
                            // Match Type Indicators
                            HStack(spacing: 8) {
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
                                    .background(PickleGoTheme.accentYellow.opacity(0.15))
                                    .foregroundColor(PickleGoTheme.accentYellow)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.bottom, 8)
                            
                            Text(teamDisplay.split(separator: " vs ")[0])
                                .font(.title2)
                                .bold()
                                .foregroundColor(PickleGoTheme.primaryGreen)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("vs")
                                .font(.title3)
                                .bold()
                                .foregroundColor(PickleGoTheme.dark.opacity(0.7))
                            
                            Text(teamDisplay.split(separator: " vs ")[1])
                                .font(.title2)
                                .bold()
                                .foregroundColor(PickleGoTheme.accentYellow)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(match.date.formatted(date: .long, time: .shortened))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Match Details
                        VStack(spacing: 16) {
                            // Location and Type
                            HStack(spacing: 20) {
                                detailPill(icon: "mappin.circle.fill", text: match.location)
                                detailPill(icon: "tennis.racket.circle.fill", text: match.matchType.rawValue)
                            }
                            
                            // Match Settings
                            HStack(spacing: 20) {
                                detailPill(icon: "number.circle.fill", text: "\(match.pointsToWin) points")
                                detailPill(icon: "trophy.circle.fill", text: "\(match.numberOfSets) sets")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Location Map
                        if let coordinate = match.locationCoordinate {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Location")
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                Map {
                                    Marker(match.location, coordinate: coordinate)
                                }
                                .frame(height: 200)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Players Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Players")
                                .font(.headline)
                                .foregroundColor(PickleGoTheme.primaryGreen)
                            
                            if match.matchType == .doubles && match.partnerSelection == .rotating {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Team Assignments")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    ForEach(0..<match.players.count, id: \.self) { index in
                                        let playerName = playerStore.displayName(for: match.players[index])
                                        let isTeam1 = index < match.players.count/2
                                        
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(isTeam1 ? PickleGoTheme.primaryGreen : PickleGoTheme.accentYellow)
                                            Text(playerName)
                                                .font(.body)
                                            if match.players[index] == authService.currentUser?.id {
                                                Text("(You)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(isTeam1 ? "Team 1" : "Team 2")
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(isTeam1 ? PickleGoTheme.primaryGreen.opacity(0.15) : PickleGoTheme.accentYellow.opacity(0.15))
                                                .foregroundColor(isTeam1 ? PickleGoTheme.primaryGreen : PickleGoTheme.accentYellow)
                                                .cornerRadius(8)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(PickleGoTheme.card)
                                        .cornerRadius(PickleGoTheme.cornerRadius)
                                    }
                                }
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(playerNames, id: \.self) { name in
                                        HStack {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(PickleGoTheme.primaryGreen)
                                            Text(name)
                                                .font(.body)
                                            if match.players.contains(where: { $0 == authService.currentUser?.id && playerStore.displayName(for: $0) == name }) {
                                                Text("(You)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(PickleGoTheme.card)
                                        .cornerRadius(PickleGoTheme.cornerRadius)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Scores Section
                        if !match.scores.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Scores")
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                VStack(spacing: 8) {
                                    ForEach(match.scores, id: \.gameNumber) { score in
                                        HStack {
                                            Text("Set \(score.gameNumber)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(score.team1Score) - \(score.team2Score)")
                                                .font(.headline)
                                                .foregroundColor(PickleGoTheme.dark)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(PickleGoTheme.card)
                                        .cornerRadius(PickleGoTheme.cornerRadius)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Notes Section
                        if let notes = match.notes {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(PickleGoTheme.dark)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(PickleGoTheme.card)
                                    .cornerRadius(PickleGoTheme.cornerRadius)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                // Action Buttons
                if match.status == .scheduled {
                    VStack(spacing: 16) {
                        Button(action: { showingCompletion = true }) {
                            HStack {
                                Spacer()
                                Label("Complete Match", systemImage: "checkmark.circle")
                                    .font(.headline)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .background(PickleGoTheme.primaryGreen)
                            .cornerRadius(PickleGoTheme.cornerRadius)
                        }
                        
                        HStack(spacing: 32) {
                            Button(action: { /* TODO: Edit match action */ }) {
                                Label("Edit", systemImage: "pencil.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                            }
                            Button(action: { showingDeleteConfirmation = true }) {
                                Label("Delete", systemImage: "trash.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(PickleGoTheme.card)
                }
            }
            .sheet(isPresented: $showingCompletion) {
                MatchCompletionView(match: match)
            }
            .alert("Delete Match", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) { deleteMatch() }
            } message: {
                Text("Are you sure you want to delete this match?")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func detailPill(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PickleGoTheme.primaryGreen)
            Text(text)
                .font(.subheadline)
                .foregroundColor(PickleGoTheme.dark)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(PickleGoTheme.card)
        .cornerRadius(PickleGoTheme.cornerRadius)
    }
    
    private func deleteMatch() {
        Task {
            do {
                try await matchViewModel.deleteMatch(match)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func updateMatch() {
        Task {
            do {
                try await matchViewModel.updateMatch(match)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    MatchDetailView(match: Match(
        id: UUID().uuidString,
        date: Date(),
        location: "Central Park Courts",
        locationCoordinate: CLLocationCoordinate2D(latitude: 40.7829, longitude: -73.9654),
        matchType: .doubles,
        pointsToWin: 15,
        numberOfSets: 3,
        players: ["Player 1", "Player 2", "Player 3", "Player 4"],
        scores: [
            Match.Score(team1Score: 11, team2Score: 9, gameNumber: 1),
            Match.Score(team1Score: 9, team2Score: 11, gameNumber: 2),
            Match.Score(team1Score: 11, team2Score: 8, gameNumber: 3)
        ],
        status: .completed,
        notes: "Practice match with focus on serving and volleying",
        isPublicFacility: false,
        partnerSelection: .fixed
    ))
    .environmentObject(MatchViewModel())
    .environmentObject(PlayerStore())
    .environmentObject(AuthenticationService())
} 