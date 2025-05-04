import Foundation
import SwiftUI
import Combine
import CoreLocation

@MainActor
class MatchViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMatches()
    }
    
    func loadMatches() {
        // Dummy data for 5 matches
        matches = [
            Match(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(3600),
                location: "Central Park Courts",
                locationCoordinate: nil,
                matchType: .doubles,
                pointsToWin: 15,
                numberOfSets: 3,
                players: ["test@test.com", "2", "3", "4"],
                scores: [],
                status: .scheduled,
                notes: "Evening match",
                isPublicFacility: true,
                partnerSelection: .fixed
            ),
            Match(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(7200),
                location: "Downtown Sports Center",
                locationCoordinate: nil,
                matchType: .singles,
                pointsToWin: 11,
                numberOfSets: 2,
                players: ["test@test.com", "5"],
                scores: [],
                status: .scheduled,
                notes: nil,
                isPublicFacility: false,
                partnerSelection: .fixed
            ),
            Match(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(-86400),
                location: "Westside Arena",
                locationCoordinate: nil,
                matchType: .doubles,
                pointsToWin: 21,
                numberOfSets: 5,
                players: ["test@test.com", "3", "4", "5"],
                scores: [
                    Match.Score(team1Score: 21, team2Score: 19, gameNumber: 1),
                    Match.Score(team1Score: 21, team2Score: 18, gameNumber: 2),
                    Match.Score(team1Score: 21, team2Score: 20, gameNumber: 3)
                ],
                status: .completed,
                notes: "Tough match!",
                isPublicFacility: true,
                partnerSelection: .rotating
            ),
            Match(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(-172800),
                location: "Eastside Gym",
                locationCoordinate: nil,
                matchType: .singles,
                pointsToWin: 15,
                numberOfSets: 3,
                players: ["test@test.com", "3"],
                scores: [
                    Match.Score(team1Score: 15, team2Score: 10, gameNumber: 1),
                    Match.Score(team1Score: 15, team2Score: 12, gameNumber: 2)
                ],
                status: .completed,
                notes: nil,
                isPublicFacility: false,
                partnerSelection: .fixed
            ),
            Match(
                id: UUID().uuidString,
                date: Date().addingTimeInterval(43200),
                location: "Lakeside Club",
                locationCoordinate: nil,
                matchType: .doubles,
                pointsToWin: 11,
                numberOfSets: 2,
                players: ["test@test.com", "4", "1", "5"],
                scores: [],
                status: .scheduled,
                notes: "Morning match",
                isPublicFacility: true,
                partnerSelection: .rotating
            )
        ]
    }
    
    func fetchMatches() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Replace with actual API call
        loadMatches()
    }
    
    func createMatch(
        date: Date,
        location: String,
        locationCoordinate: CLLocationCoordinate2D?,
        matchType: Match.MatchType,
        pointsToWin: Int,
        numberOfSets: Int,
        players: [String],
        notes: String?,
        isPublicFacility: Bool,
        partnerSelection: Match.PartnerSelection
    ) async throws {
        let match = Match(
            id: UUID().uuidString,
            date: date,
            location: location,
            locationCoordinate: locationCoordinate,
            matchType: matchType,
            pointsToWin: pointsToWin,
            numberOfSets: numberOfSets,
            players: players,
            scores: [],
            status: .scheduled,
            notes: notes,
            isPublicFacility: isPublicFacility,
            partnerSelection: partnerSelection
        )
        
        // TODO: Replace with actual API call
        matches.append(match)
    }
    
    func deleteMatch(_ match: Match) async throws {
        // TODO: Replace with actual API call
        matches.removeAll { $0.id == match.id }
    }
    
    func updateMatch(_ match: Match) async throws {
        // TODO: Replace with actual API call
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
        }
    }
    
    func updateMatchScore(matchId: String, team1Score: Int, team2Score: Int, gameNumber: Int) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if let index = matches.firstIndex(where: { $0.id == matchId }) {
            var match = matches[index]
            let newScore = Match.Score(team1Score: team1Score, team2Score: team2Score, gameNumber: gameNumber)
            match.scores.append(newScore)
            matches[index] = match
        }
    }
} 