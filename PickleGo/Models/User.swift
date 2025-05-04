import Foundation

struct User: Identifiable, Codable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var friends: [String] // Array of user IDs
    var matches: [String] // Array of match IDs
} 