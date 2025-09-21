import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var onboarding = OnboardingState()
    var home = HomeState()
    var quiz = QuizState()
    var favorites = FavoritesState()
    var profile = ProfileState()
    var friends = FriendsState()
    var challenges = ChallengesState()
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
    var streakDays: Int = 0  // Missing property referenced in HomeView
}

enum QuizViewMode: Equatable {
    case overview
    case playing
    case result
    case history
}

enum FavoritesViewMode: String, Equatable, CaseIterable {
    case list = "list"
    case grid = "grid"
    
    var displayName: String {
        switch self {
        case .list:
            return "Lista"
        case .grid:
            return "Rutnät"
        }
    }
    
    var icon: String {
        switch self {
        case .list:
            return "list.bullet"
        case .grid:
            return "square.grid.2x2"
        }
    }
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
    
    // Challenge mode properties
    var challengeStage: ChallengeStage? = nil
    var playerOneScore: Int = 0
    var playerTwoScore: Int = 0
}

enum ChallengeStage: Equatable {
    case player1
    case player2
    case finished
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
        language: UserDefaults.standard.string(forKey: "language") ?? "sv",
        displayName: UserDefaults.standard.string(forKey: "displayName") ?? "Gäst",
        avatar: AvatarType(rawValue: UserDefaults.standard.string(forKey: "avatarType") ?? "initials") ?? .initials
    )
    var avatarData: AvatarData = {
        if let data = UserDefaults.standard.data(forKey: "avatarData"),
           let avatarData = try? JSONDecoder().decode(AvatarData.self, from: data) {
            return avatarData
        }
        return AvatarData.default
    }()
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
    var leveledUp: Bool = false
    var challengeCompleted: Bool = false
}

struct FriendsState: Equatable {
    var friends: [Friend] = []
    var pendingRequests: [Friend] = []
    var sentRequests: [Friend] = []
    var isLoading = false
    
    // Missing properties that are referenced in reducer
    var showingAddFriend = false
    var newFriendName = ""
    var isFindingOpponent = false
    var currentMatch: Match?
    var matchResult: MatchResult?
    var showingMatchResult = false
    var pendingChallenges: [UUID] = []
}

struct ChallengesState: Equatable {
    var dailyChallenges: [Challenge] = []
    var weeklyChallenges: [Challenge] = []
    var recentlyCompletedChallenge: Challenge?
    var challengeCompleted = false
}

struct Friend: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let avatar: String
    let level: Int
    let isOnline: Bool
    let totalFactsRead: Int
    let bestStreak: Int
}

struct Challenge: Identifiable, Equatable {
    let id = UUID()
    let description: String
    let target: Int
    var progress: Int
    var isCompleted: Bool
    let isDaily: Bool
    let rewardXP: Int // XP reward
    let icon: String
    let color: String
}

struct Match: Identifiable, Equatable {
    let id = UUID()
    let opponent: Opponent
    let result: MatchResult
    let date: Date
}

struct MatchResult: Equatable {
    let playerScore: Int
    let opponentScore: Int
    let isWinner: Bool
}

struct Opponent: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let avatar: String
    let level: Int
    let isOnline: Bool
}



