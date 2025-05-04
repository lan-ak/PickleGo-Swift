import Foundation

struct User: Identifiable, Codable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var skillLevel: SkillLevel
    var friends: [String] // Array of user IDs
    var matches: [String] // Array of match IDs
    
    enum SkillLevel: String, Codable, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case pro = "Professional"
    }
} 