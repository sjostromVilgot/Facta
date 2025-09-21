import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var onboarding = OnboardingState()
    var home = HomeState()
    var quiz = QuizState()
    var favorites = FavoritesState()
    var profile = ProfileState()
    var onboardingComplete: Bool = UserDefaults.standard.bool(forKey: "facta-onboarding-complete")
}

// MARK: - Feature States

struct OnboardingState: Equatable {
    var currentStep: Int = 0
    var notificationsEnabled: Bool = false
    var dailyFactEnabled: Bool = true
    var quizReminderEnabled: Bool = false
    var isComplete: Bool = false
}

struct HomeState: Equatable {
    var dailyFact: Fact?
    var discovery: [Fact] = []
    var index: Int = 0
    var isLoading: Bool = false
    var favorites: Set<String> = []
}

enum QuizViewMode: Equatable {
    case overview
    case playing
    case result
    case history
}

struct QuizState: Equatable {
    var mode: QuizViewMode = .overview
    var quizMode: QuizMode? = nil
    var questions: [QuizQuestion] = []
    var i: Int = 0
    var score: Int = 0
    var streak: Int = 0
    var timeLeft: Int = 0
    var history: [QuizResult] = []
}

enum FavoritesViewMode: Equatable {
    case grid
    case list
}

struct FavoritesState: Equatable {
    var items: [Fact] = []
    var query: String = ""
    var category: String = "Alla"
    var viewMode: FavoritesViewMode = .grid
}

struct ProfileState: Equatable {
    var settings: UserSettings = UserSettings(
        dailyFactNotifications: UserDefaults.standard.object(forKey: "daily-fact-notifications") as? Bool ?? true,
        quizReminders: UserDefaults.standard.object(forKey: "quiz-reminders") as? Bool ?? false,
        theme: ThemeChoice(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "system") ?? .system,
        language: UserDefaults.standard.string(forKey: "language") ?? "sv"
    )
    var stats: UserStats = UserStats(
        streakDays: 0,
        totalFactsRead: 0,
        totalQuizzes: 0,
        avgQuizScore: 0,
        bestQuizStreak: 0,
        badgesUnlocked: 0,
        favoriteCategory: nil,
        joinDate: Date()
    )
    var badges: [Badge] = []
}


