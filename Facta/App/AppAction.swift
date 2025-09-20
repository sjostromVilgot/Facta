import Foundation
import ComposableArchitecture

enum AppAction {
    case onboarding(OnboardingAction)
    case home(HomeAction)
    case quiz(QuizAction)
    case favorites(FavoritesAction)
    case profile(ProfileAction)
    case setOnboardingComplete(Bool)
}

// MARK: - Feature Actions

enum OnboardingAction {
    case nextStep
    case getStartedTapped
    case notificationPermissionResponse(Bool)
    case toggleDailyFact(Bool)
    case finish
}

enum HomeAction {
    case onAppear
    case dailyLoaded(Fact)
    case discoveryLoaded([Fact])
    case save(Fact)
    case next
    case shuffle
    case share(Fact)
    case markRead(Fact)
}

enum QuizAction {
    case start(QuizMode)
    case questionsLoaded([QuizQuestion])
    case tick
    case answerIndex(Int?)
    case answerBool(Bool)
    case next
    case showHistory
    case backToOverview
}

enum FavoritesAction {
    case reload
    case setQuery(String)
    case setCategory(String)
    case setViewMode(FavoritesViewMode)
    case remove(String)
    case share(Fact)
}

enum ProfileAction {
    case load
    case toggleDailyFact(Bool)
    case toggleQuizReminder(Bool)
    case setTheme(ThemeChoice)
    case setLanguage(String)
}
