import Foundation
import SwiftUI

struct Friend: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let avatar: String
    let level: Int
    let joinDate: Date
    let totalFactsRead: Int
    let bestStreak: Int
    let isOnline: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        avatar: String = "👤",
        level: Int = 1,
        joinDate: Date = Date(),
        totalFactsRead: Int = 0,
        bestStreak: Int = 0,
        isOnline: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.level = level
        self.joinDate = joinDate
        self.totalFactsRead = totalFactsRead
        self.bestStreak = bestStreak
        self.isOnline = isOnline
    }
}

// MARK: - Sample Data
extension Friend {
    static let sampleFriends: [Friend] = [
        Friend(
            name: "Anna",
            avatar: "👩‍💼",
            level: 5,
            joinDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            totalFactsRead: 150,
            bestStreak: 12,
            isOnline: true
        ),
        Friend(
            name: "Erik",
            avatar: "👨‍🔬",
            level: 3,
            joinDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            totalFactsRead: 75,
            bestStreak: 8,
            isOnline: false
        ),
        Friend(
            name: "Maria",
            avatar: "👩‍🎓",
            level: 7,
            joinDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            totalFactsRead: 200,
            bestStreak: 15,
            isOnline: true
        ),
        Friend(
            name: "Lars",
            avatar: "👨‍🏫",
            level: 4,
            joinDate: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            totalFactsRead: 100,
            bestStreak: 10,
            isOnline: false
        )
    ]
}
