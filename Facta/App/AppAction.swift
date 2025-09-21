import Foundation
import ComposableArchitecture

enum AppAction {
    case onboarding(OnboardingAction)
    case home(HomeAction)
    case quiz(QuizAction)
    case favorites(FavoritesAction)
    case profile(ProfileAction)
    case friends(FriendsAction)
    case challenges(ChallengesAction)
    case setOnboardingComplete(Bool)
}

// MARK: - Feature Actions

enum OnboardingAction: Equatable {
    case nextStep
    case getStartedTapped
    case notificationPermissionResponse(Bool)
    case toggleDailyFact(Bool)
    case toggleQuizReminder(Bool)
    case finish
}

enum HomeAction: Equatable {
    case onAppear
    case load
    case dailyLoaded(Fact)
    case discoveryLoaded([Fact])
    case save(Fact)
    case next
    case shuffle
    case share(Fact)
    case markRead(Fact)
}

enum QuizAction: Equatable {
    case start(QuizMode)
    case questionsLoaded([QuizQuestion])
    case tick
    case answerIndex(Int?)
    case answerBool(Bool)
    case answerText(String)
    case next
    case nextPlayer
    case showHistory
    case backToOverview
    case result(QuizResult)
    case challengeCompleted(QuizMode, QuizResult)
}

enum FavoritesAction: Equatable {
    case load
    case reload
    case setQuery(String)
    case setCategory(String)
    case setViewMode(FavoritesViewMode)
    case remove(Fact)
}

enum ProfileAction: Equatable {
    case load
    case toggleDailyFact(Bool)
    case toggleQuizReminder(Bool)
    case setTheme(ThemeChoice)
    case setLanguage(String)
    case setDisplayName(String)
    case setAvatar(AvatarData)
    case updateStreak
    case acknowledgeLevelUp
    case acknowledgeChallengeComplete
}

enum FriendsAction: Equatable {
    case load
    case addFriend(String)
    case acceptRequest(UUID)
    case declineRequest(UUID)
    case removeFriend(UUID)
    case challengeFriend(UUID)
    case setShowingAddFriend(Bool)
    case setNewFriendName(String)
    case startQuizWithFriend(UUID)
    case quickMatch
    case opponentFound(Opponent)
    case matchStarted(Match)
    case matchCompleted(MatchResult)
}

enum ChallengesAction: Equatable {
    case load
    case markComplete(UUID)
    case incrementProgress(UUID, Int)
    case resetDailyChallenges
    case resetWeeklyChallenges
    case acknowledgeChallengeComplete
}
