import Foundation

struct Player: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var email: String?
    var phoneNumber: String?
    var isRegistered: Bool      // true if the player has an account
    var isInvited: Bool         // true if the player was invited but hasn't accepted
    var skillLevel: User.SkillLevel
    var profileImageURL: String?
    
    static func fromUser(_ user: User) -> Player {
        Player(
            id: user.id,
            name: user.username,
            email: user.email,
            phoneNumber: nil,
            isRegistered: true,
            isInvited: false,
            skillLevel: user.skillLevel,
            profileImageURL: user.profileImageURL
        )
    }
    
    static func mockPlayers() -> [Player] {
        return [
            Player(id: UUID().uuidString, name: "John Smith", email: "john@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, skillLevel: .intermediate, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Sarah Johnson", email: "sarah@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, skillLevel: .advanced, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Mike Davis", email: "mike@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, skillLevel: .beginner, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Emily Wilson", email: "emily@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, skillLevel: .intermediate, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "David Brown", email: nil, phoneNumber: nil, isRegistered: false, isInvited: false, skillLevel: .beginner, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Lisa Anderson", email: nil, phoneNumber: nil, isRegistered: false, isInvited: true, skillLevel: .advanced, profileImageURL: nil)
        ]
    }
} 