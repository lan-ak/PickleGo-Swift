import Foundation

struct Player: Identifiable, Codable {
    let id: String
    var name: String
    var email: String?
    var phoneNumber: String?
    var isRegistered: Bool
    var isInvited: Bool
    var profileImageURL: String?
    
    init(id: String, name: String, email: String? = nil, phoneNumber: String? = nil, isRegistered: Bool, isInvited: Bool, profileImageURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.isRegistered = isRegistered
        self.isInvited = isInvited
        self.profileImageURL = profileImageURL
    }
    
    static func fromUser(_ user: User) -> Player {
        Player(
            id: user.id,
            name: user.username,
            email: user.email,
            phoneNumber: nil,
            isRegistered: true,
            isInvited: false,
            profileImageURL: user.profileImageURL
        )
    }
    
    static func mockPlayers() -> [Player] {
        return [
            Player(id: UUID().uuidString, name: "John Smith", email: "john@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Sarah Johnson", email: "sarah@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Mike Davis", email: "mike@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Emily Wilson", email: "emily@example.com", phoneNumber: nil, isRegistered: true, isInvited: false, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "David Brown", email: nil, phoneNumber: nil, isRegistered: false, isInvited: false, profileImageURL: nil),
            Player(id: UUID().uuidString, name: "Lisa Anderson", email: nil, phoneNumber: nil, isRegistered: false, isInvited: true, profileImageURL: nil)
        ]
    }
} 