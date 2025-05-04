import Foundation
import Combine

class PlayerStore: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let playersSubject = CurrentValueSubject<[Player], Never>([])
    
    @Published private(set) var players: [Player] = [
        Player(id: "1", name: "John Smith", email: "john1@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "2", name: "Sarah Johnson", email: "sarah2@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "3", name: "Mike Davis", email: "mike3@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "4", name: "Emily Wilson", email: "emily4@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "5", name: "David Brown", email: "david5@example.com", phoneNumber: nil, isRegistered: false, isInvited: true, profileImageURL: nil)
    ].filter { !$0.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    static let samplePlayers = [
        Player(id: "1", name: "John Smith", email: "john1@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "2", name: "Sarah Johnson", email: "sarah2@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "3", name: "Mike Davis", email: "mike3@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "4", name: "Emily Wilson", email: "emily4@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
        Player(id: "5", name: "David Brown", email: "david5@example.com", phoneNumber: nil, isRegistered: false, isInvited: true, profileImageURL: nil)
    ]
    
    init() {
        playersSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$players)
    }
    
    func name(for id: String) -> String {
        players.first(where: { $0.id == id })?.name ?? "Unknown"
    }
    
    func player(for id: String) -> Player? {
        players.first(where: { $0.id == id })
    }
    
    func displayName(for id: String) -> String {
        if let player = player(for: id) {
            return player.name
        }
        // Fallback: if id looks like an email or UUID, return "Guest"
        if id.contains("@") || id.range(of: "[0-9a-fA-F-]{36}", options: .regularExpression) != nil {
            return "Guest"
        }
        return id
    }
    
    func player(forEmail email: String) -> Player? {
        players.first(where: { $0.email == email })
    }
    
    func invitedPlayers() -> [Player] {
        players.filter { $0.isInvited }
    }
    
    func addIfNeeded(_ player: Player) {
        if !players.contains(where: { $0.id == player.id }) {
            var updatedPlayers = players
            updatedPlayers.append(player)
            playersSubject.send(updatedPlayers)
        }
    }
    
    func savePlayer(_ player: Player) async throws {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            var updatedPlayers = players
            updatedPlayers[index] = player
            playersSubject.send(updatedPlayers)
        } else {
            var updatedPlayers = players
            updatedPlayers.append(player)
            playersSubject.send(updatedPlayers)
        }
    }
    
    func isRegistered(_ id: String) -> Bool {
        player(for: id)?.isRegistered ?? false
    }
} 