import Foundation

struct Badge: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String // emoji eller SF-symbolnamn
    var isUnlocked: Bool
    var unlockedDate: Date?
}