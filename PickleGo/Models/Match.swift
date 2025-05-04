import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

struct Match: Identifiable, Codable {
    let id: String
    var date: Date
    var location: String
    var locationCoordinate: CLLocationCoordinate2D?
    var matchType: MatchType
    var pointsToWin: Int
    var numberOfSets: Int
    var players: [String] // Array of user IDs
    var scores: [Score]
    var status: MatchStatus
    var notes: String?
    let isPublicFacility: Bool
    
    struct Score: Codable {
        var team1Score: Int
        var team2Score: Int
        var gameNumber: Int
    }
    
    enum MatchStatus: String, Codable {
        case scheduled = "Scheduled"
        case inProgress = "In Progress"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
    
    enum MatchType: String, Codable, CaseIterable {
        case singles = "Singles"
        case doubles = "Doubles"
    }
} 