import SwiftUI

struct TeamDisplay {
    let match: Match
    let playerStore: PlayerStore
    
    func getPlayerName(at index: Int) -> String {
        guard index < match.players.count else { return "Unknown Player" }
        return playerStore.displayName(for: match.players[index])
    }
    
    var team1: String {
        if match.matchType == .singles {
            return getPlayerName(at: 0)
        }
        return "\(getPlayerName(at: 0)) & \(getPlayerName(at: 1))"
    }
    
    var team2: String {
        if match.matchType == .singles {
            return getPlayerName(at: 1)
        }
        return "\(getPlayerName(at: 2)) & \(getPlayerName(at: 3))"
    }
    
    var display: String {
        "\(team1) vs \(team2)"
    }
} 