import Foundation
import SwiftUI

struct Friend: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let avatar: String
    let joinDate: Date
    let totalFactsRead: Int
    let bestStreak: Int
    let isOnline: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        avatar: String = "👤",
        joinDate: Date = Date(),
        totalFactsRead: Int = 0,
        bestStreak: Int = 0,
        isOnline: Bool = false
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
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
            joinDate: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date(),
            totalFactsRead: 45,
            bestStreak: 12,
            isOnline: true
        ),
        Friend(
            name: "Erik",
            avatar: "👨‍🔬",
            joinDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            totalFactsRead: 28,
            bestStreak: 8,
            isOnline: false
        ),
        Friend(
            name: "Maria",
            avatar: "👩‍🎓",
            joinDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            totalFactsRead: 15,
            bestStreak: 5,
            isOnline: true
        ),
        Friend(
            name: "Lars",
            avatar: "👨‍🏫",
            joinDate: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            totalFactsRead: 78,
            bestStreak: 20,
            isOnline: false
        )
    ]
}
