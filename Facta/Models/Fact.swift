import Foundation

struct FactTag: Codable, Hashable {
    let emoji: String
    let label: String
}

struct Fact: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: String
    let tags: [FactTag]
    let readTime: Int?        // sek
    let isPremium: Bool
}