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
    @State private var showingEditMatch = false
    @State private var region: MKCoordinateRegion
    
    init(match: Match) {
        self.match = match
        if let coordinate = match.locationCoordinate {
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    private var playerNames: [String] {
        match.players.map { playerStore.displayName(for: $0) }
    }
    
    private var teamDisplay: String {
        let names = match.players.map { playerStore.displayName(for: $0) }
        
        if match.matchType == .singles {
            if names.count == 2 {
                return "\(names[0]) vs \(names[1])"
            }
            return names.joined(separator: ", ")
        } else {
            if names.count == 4 {
                let team1 = "\(names[0]) & \(names[1])"
                let team2 = "\(names[2]) & \(names[3])"
                return "\(team1) vs \(team2)"
            }
            return names.joined(separator: ", ")
        }
    }
    
    private var matchStatusBanner: some View {
        Group {
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
        }
    }
    
    private var matchTitle: some View {
        VStack(spacing: 16) {
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
            .padding(.bottom, 12)
            
            let teams = teamDisplay.split(separator: " vs ")
            Text(teams[0])
                .font(.title2)
                .bold()
                .foregroundColor(PickleGoTheme.primaryGreen)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("vs")
                .font(.title3)
                .bold()
                .foregroundColor(PickleGoTheme.dark.opacity(0.7))
                .padding(.vertical, 4)
            
            Text(teams[1])
                .font(.title2)
                .bold()
                .foregroundColor(PickleGoTheme.accentYellow)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text(match.date.formatted(date: .long, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var matchDetails: some View {
        VStack(spacing: 16) {
            // Match Type and Settings
            HStack(spacing: 20) {
                detailPill(icon: match.matchType == .singles ? "person.fill" : "person.2.fill", text: match.matchType.rawValue)
                detailPill(icon: "number.circle.fill", text: "\(match.pointsToWin) points")
                detailPill(icon: "trophy.circle.fill", text: "\(match.numberOfSets) sets")
            }
        }
        .padding(.horizontal)
    }
    
    private var locationMap: AnyView {
        if !match.location.isEmpty {
            let mapContent = VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.primaryGreen)
                
                if let coordinate = match.locationCoordinate {
                    Map {
                        Marker(match.location, coordinate: coordinate)
                    }
                    .mapStyle(.standard)
                    .frame(height: 120)
                    .cornerRadius(PickleGoTheme.cornerRadius)
                }
                
                Text(match.location)
                    .font(.subheadline)
                    .foregroundColor(PickleGoTheme.dark)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            return AnyView(mapContent)
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func setView(for setNumber: Int) -> AnyView {
        let header = HStack {
            Text("Set \(setNumber)")
                .font(.title3)
                .bold()
                .foregroundColor(PickleGoTheme.primaryGreen)
            Spacer()
            Text("First to \(match.pointsToWin) points")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        
        let partnersView: AnyView
        if match.matchType == .doubles {
            if match.partnerSelection == .rotating {
                partnersView = AnyView(rotatingPartnersView(for: setNumber))
            } else {
                partnersView = AnyView(fixedPartnersView())
            }
        } else {
            partnersView = AnyView(EmptyView())
        }
        
        let scoreView: AnyView
        if let score = match.scores.first(where: { $0.gameNumber == setNumber }) {
            scoreView = AnyView(self.scoreView(score: score))
        } else {
            scoreView = AnyView(EmptyView())
        }
        
        let content = VStack(alignment: .leading, spacing: 8) {
            header
            partnersView
            scoreView
        }
        .padding()
        .background(PickleGoTheme.card)
        .cornerRadius(PickleGoTheme.cornerRadius)
        
        return AnyView(content)
    }
    
    private func scoreView(score: Match.Score) -> AnyView {
        let content = HStack {
            Spacer()
            Text("\(score.team1Score) - \(score.team2Score)")
                .font(.title2)
                .bold()
                .foregroundColor(PickleGoTheme.dark)
            Spacer()
        }
        .padding(.top, 8)
        
        return AnyView(content)
    }
    
    private var gamesSchedule: AnyView {
        let content = VStack(alignment: .leading, spacing: 12) {
            Text("Games Schedule")
                .font(.headline)
                .foregroundColor(PickleGoTheme.primaryGreen)
            
            VStack(spacing: 16) {
                ForEach(1...match.numberOfSets, id: \.self) { setNumber in
                    setView(for: setNumber)
                }
            }
        }
        .padding(.horizontal)
        
        return AnyView(content)
    }
    
    private var matchResults: AnyView {
        if !match.scores.isEmpty && match.status == .completed {
            let content = VStack(alignment: .leading, spacing: 12) {
                Text("Match Results")
                    .font(.headline)
                    .foregroundColor(PickleGoTheme.primaryGreen)
                
                let team1Wins = match.scores.filter { $0.team1Score > $0.team2Score }.count
                let team2Wins = match.scores.filter { $0.team2Score > $0.team1Score }.count
                
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("\(team1Wins) - \(team2Wins)")
                            .font(.title)
                            .bold()
                            .foregroundColor(PickleGoTheme.dark)
                        Text(team1Wins > team2Wins ? "Team 1 Wins!" : "Team 2 Wins!")
                            .font(.headline)
                            .foregroundColor(team1Wins > team2Wins ? PickleGoTheme.primaryGreen : PickleGoTheme.accentYellow)
                    }
                    Spacer()
                }
                .padding()
                .background(PickleGoTheme.card)
                .cornerRadius(PickleGoTheme.cornerRadius)
            }
            .padding(.horizontal)
            
            return AnyView(content)
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var notesSection: AnyView {
        if let notes = match.notes {
            let content = VStack(alignment: .leading, spacing: 12) {
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
            
            return AnyView(content)
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var body: some View {
        ZStack {
            PickleGoTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        matchStatusBanner
                        matchTitle
                        matchDetails
                        locationMap
                        gamesSchedule
                        matchResults
                        notesSection
                    }
                    .padding(.vertical)
                }
                
                // Action Buttons
                if match.status == .scheduled {
                    VStack(spacing: 16) {
                        Button(action: { showingCompletion = true }) {
                            Label("Enter Scores", systemImage: "checkmark.circle")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(PickleGoTheme.primaryGreen)
                                .cornerRadius(PickleGoTheme.cornerRadius)
                        }
                        
                        HStack(spacing: 32) {
                            Button(action: { showingEditMatch = true }) {
                                Text("Edit")
                                    .font(.subheadline)
                                    .foregroundColor(PickleGoTheme.primaryGreen)
                                    .padding(.horizontal, 8)
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                            }
                            
                            Button(action: { showingDeleteConfirmation = true }) {
                                Text("Delete")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(PickleGoTheme.card)
                }
            }
            .sheet(isPresented: $showingCompletion) {
                MatchCompletionView(match: match)
            }
            .sheet(isPresented: $showingEditMatch) {
                MatchCreationView(match: match)
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
    
    private struct TeamView: View {
        let title: String
        let player1: String
        let player2: String
        let color: Color
        @EnvironmentObject var playerStore: PlayerStore
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(color)
                Text(playerStore.displayName(for: player1))
                    .font(.caption2)
                Text(playerStore.displayName(for: player2))
                    .font(.caption2)
            }
        }
    }
    
    private func rotatingPartnersView(for setNumber: Int) -> some View {
        let player1 = match.players[0]
        let player2 = match.players[1]
        let player3 = match.players[2]
        let player4 = match.players[3]
        
        let (team1Player1, team1Player2, team2Player1, team2Player2): (String, String, String, String) = {
            switch (setNumber - 1) % 5 {
            case 0: return (player1, player2, player3, player4)
            case 1: return (player1, player3, player2, player4)
            case 2: return (player1, player4, player2, player3)
            case 3: return (player2, player3, player1, player4)
            case 4: return (player2, player4, player1, player3)
            default: return (player1, player2, player3, player4)
            }
        }()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Set \(setNumber) Teams")
                .font(.headline)
                .foregroundColor(PickleGoTheme.primaryGreen)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Team 1")
                    .font(.subheadline)
                    .foregroundColor(PickleGoTheme.primaryGreen)
                
                HStack(spacing: 4) {
                    Text(playerStore.displayName(for: team1Player1))
                        .font(.subheadline)
                    Image(systemName: "person.fill")
                        .foregroundColor(PickleGoTheme.primaryGreen)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PickleGoTheme.card)
                .cornerRadius(8)
                
                HStack(spacing: 4) {
                    Text(playerStore.displayName(for: team1Player2))
                        .font(.subheadline)
                    Image(systemName: "person.fill")
                        .foregroundColor(PickleGoTheme.primaryGreen)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PickleGoTheme.card)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Team 2")
                    .font(.subheadline)
                    .foregroundColor(PickleGoTheme.accentYellow)
                
                HStack(spacing: 4) {
                    Text(playerStore.displayName(for: team2Player1))
                        .font(.subheadline)
                    Image(systemName: "person.fill")
                        .foregroundColor(PickleGoTheme.accentYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PickleGoTheme.card)
                .cornerRadius(8)
                
                HStack(spacing: 4) {
                    Text(playerStore.displayName(for: team2Player2))
                        .font(.subheadline)
                    Image(systemName: "person.fill")
                        .foregroundColor(PickleGoTheme.accentYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(PickleGoTheme.card)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(PickleGoTheme.background)
        .cornerRadius(16)
    }
    
    private func fixedPartnersView() -> HStack<TupleView<(TeamView, TeamView)>> {
        return HStack(spacing: 16) {
            TeamView(title: "Team 1", player1: match.players[0], player2: match.players[1], color: PickleGoTheme.primaryGreen)
            TeamView(title: "Team 2", player1: match.players[2], player2: match.players[3], color: PickleGoTheme.accentYellow)
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