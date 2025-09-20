import Foundation

enum ThemeChoice: String, Codable {
    case system
    case light
    case dark
}

struct UserSettings: Codable, Equatable {
    var dailyFactNotifications: Bool
    var quizReminders: Bool
    var theme: ThemeChoice
    var language: String // "sv"
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
}