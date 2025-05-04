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
                    VStack(spacing: 28) {
                        if match.status == .completed, let userId = authService.currentUser?.id {
                            let isTeam1 = match.players.prefix(match.players.count/2).contains(userId)
                            let isTeam2 = match.players.suffix(match.players.count/2).contains(userId)
                            
                            // Calculate total sets won by each team
                            let team1Wins = match.scores.filter { $0.team1Score > $0.team2Score }.count
                            let team2Wins = match.scores.filter { $0.team2Score > $0.team1Score }.count
                            
                            let didWin: Bool = {
                                if isTeam1 { return team1Wins > team2Wins }
                                if isTeam2 { return team2Wins > team1Wins }
                                return false
                            }()
                            
                            HStack {
                                Image(systemName: didWin ? "checkmark.seal.fill" : "xmark.seal.fill")
                                    .foregroundColor(.white)
                                    .font(.title)
                                Text(didWin ? "You Won!" : "You Lost")
                                    .font(.title2).bold()
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(didWin ? PickleGoTheme.primaryGreen : Color.red)
                            .cornerRadius(PickleGoTheme.cornerRadius)
                            .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
                            .padding(.horizontal)
                        }
                        Text(teamDisplay)
                            .font(.title2).bold()
                            .foregroundColor(PickleGoTheme.primaryGreen)
                            .padding(.bottom, 8)
                        VStack(alignment: .leading, spacing: 20) {
                            cardSection {
                                Section(header: sectionHeader("Match Details")) {
                                    detailRow("Date", match.date.formatted(date: .long, time: .shortened))
                                    detailRow("Location", match.location)
                                    detailRow("Type", match.matchType.rawValue)
                                    detailRow("Points to Win", "\(match.pointsToWin)")
                                    detailRow("Number of Sets", "\(match.numberOfSets)")
                                }
                            }
                            if let coordinate = match.locationCoordinate {
                                cardSection {
                                    Section(header: sectionHeader("Location Map")) {
                                        Map {
                                            Marker(match.location, coordinate: coordinate)
                                        }
                                        .frame(height: 220)
                                        .cornerRadius(16)
                                        .padding(.top, 8)
                                    }
                                }
                            }
                            cardSection {
                                Section(header: sectionHeader("Players")) {
                                    ForEach(playerNames, id: \.self) { name in
                                        Text(name)
                                            .font(.body)
                                            .padding(.vertical, 2)
                                    }
                                }
                            }
                            if !match.scores.isEmpty {
                                cardSection {
                                    Section(header: sectionHeader("Scores")) {
                                        ForEach(match.scores, id: \.gameNumber) { score in
                                            HStack {
                                                Text("Set \(score.gameNumber)")
                                                Spacer()
                                                Text("\(score.team1Score) - \(score.team2Score)")
                                            }
                                            .font(.body)
                                            .padding(.vertical, 2)
                                        }
                                    }
                                }
                            }
                            if let notes = match.notes {
                                cardSection {
                                    Section(header: sectionHeader("Notes")) {
                                        Text(notes)
                                            .font(.body)
                                            .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                if match.status == .scheduled {
                    VStack(spacing: 12) {
                        Button(action: { showingCompletion = true }) {
                            HStack {
                                Spacer()
                                Label("Complete Match", systemImage: "checkmark.circle")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(PickleGoTheme.primaryGreen)
                            .cornerRadius(PickleGoTheme.cornerRadius * 1.5)
                            .shadow(color: PickleGoTheme.shadow, radius: 6, y: 3)
                        }
                        HStack(spacing: 24) {
                            Button(action: { /* TODO: Edit match action */ }) {
                                Label("Edit", systemImage: "pencil")
                                    .font(.body)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                            }
                            Button(action: { showingDeleteConfirmation = true }) {
                                Text("Delete Match")
                                    .font(.body)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
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
}

private func cardSection<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 0) {
        content()
    }
    .padding()
    .background(PickleGoTheme.card)
    .cornerRadius(PickleGoTheme.cornerRadius)
    .shadow(color: PickleGoTheme.shadow, radius: 4, y: 2)
    .padding(.vertical, 6)
}

private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.title3).bold()
        .foregroundColor(PickleGoTheme.primaryGreen)
        .padding(.bottom, 4)
}

private func detailRow(_ label: String, _ value: String) -> some View {
    HStack {
        Text(label)
            .font(.body)
            .foregroundColor(.secondary)
        Spacer()
        Text(value)
            .font(.body)
            .foregroundColor(PickleGoTheme.dark)
    }
}

#Preview {
    MatchDetailView(match: Match(
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
        notes: "Practice match",
        isPublicFacility: false
    ))
    .environmentObject(MatchViewModel())
    .environmentObject(PlayerStore())
} 