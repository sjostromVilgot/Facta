import Foundation

enum ThemeChoice: String, Codable {
    case system
    case light
    case dark
    case mint
    case ocean
    case sunset
}

struct UserSettings: Codable, Equatable {
    var dailyFactNotifications: Bool
    var quizReminders: Bool
    var theme: ThemeChoice
    var language: String // "sv"
    var displayName: String
    var avatar: AvatarType
}

enum AvatarType: String, Codable, CaseIterable {
    case initials = "initials"
    case emoji = "emoji"
    case systemIcon = "systemIcon"
    
    var displayName: String {
        switch self {
        case .initials:
            return "Initialer"
        case .emoji:
            return "Emoji"
        case .systemIcon:
            return "Ikon"
        }
    }
}

struct AvatarData: Codable, Equatable {
    var type: AvatarType
    var emoji: String?
    var systemIcon: String?
    var initials: String?
    
    static let `default` = AvatarData(
        type: .initials,
        emoji: nil,
        systemIcon: nil,
        initials: "G"
    )
}

struct UserStats: Codable, Equatable {
    var streakDays: Int
    var totalFactsRead: Int
    var totalQuizzes: Int
    var avgQuizScore: Int
    var bestQuizStreak: Int
    var badgesUnlocked: Int
    var favoriteCategory: String?
    var joinDate: Date
    
    // Level system
    var currentXP: Int = 0
    var level: Int = 1
    var previousLevel: Int = 1
    var hasLeveledUp: Bool = false
    
    // XP and Level properties
    var xp: Int = 0
    var totalLevel: Int = 1
    
    // Calculate XP from stats
    var calculatedXP: Int {
        return 10 * totalFactsRead + 25 * totalQuizzes + 5 * streakDays + 50 * badgesUnlocked
    }
    
    // Calculate level from XP
    var calculatedLevel: Int {
        return max(1, calculatedXP / 100)
    }
    
    // XP needed for next level
    var xpForNextLevel: Int {
        let nextLevel = calculatedLevel + 1
        return nextLevel * 100
    }
    
    // XP progress towards next level
    var xpProgress: Int {
        return calculatedXP % 100
    }
}