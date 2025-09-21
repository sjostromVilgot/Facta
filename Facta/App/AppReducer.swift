import Foundation
import ComposableArchitecture

struct AppReducer: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.notificationClient) var notificationClient
    @Dependency(\.gameCenterClient) var gameCenterClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: /AppAction.onboarding) {
            OnboardingReducer()
        }
        
        Scope(state: \.home, action: /AppAction.home) {
            HomeReducer()
        }
        
        Scope(state: \.quiz, action: /AppAction.quiz) {
            QuizReducer()
        }
        
        Scope(state: \.favorites, action: /AppAction.favorites) {
            FavoritesReducer()
        }
        
        Scope(state: \.profile, action: /AppAction.profile) {
            ProfileReducer()
        }
        
        Scope(state: \.friends, action: /AppAction.friends) {
            FriendsReducer()
        }
        
        Scope(state: \.challenges, action: /AppAction.challenges) {
            ChallengesReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .setOnboardingComplete(let isComplete):
                state.onboardingComplete = isComplete
                UserDefaults.standard.set(isComplete, forKey: "facta-onboarding-complete")
                return .none
                
            default:
                return .none
            }
        }
    }
}

// MARK: - OnboardingReducer
struct OnboardingReducer: Reducer {
    typealias State = OnboardingState
    typealias Action = OnboardingAction
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextStep:
                if state.currentStep < 4 {
                    state.currentStep += 1
                }
                return .none
                
                    case .getStartedTapped:
                state.isComplete = true
                return .none
                
            case .notificationPermissionResponse(let granted):
                state.notificationsEnabled = granted
                return .none
                
            case .toggleDailyFact(let enabled):
                state.dailyFactEnabled = enabled
                return .none
                
            case .toggleQuizReminder(let enabled):
                state.quizReminderEnabled = enabled
                return .none
                
            case .finish:
                state.isComplete = true
                return .none
            }
        }
    }
}

// MARK: - HomeReducer
struct HomeReducer: Reducer {
    typealias State = HomeState
    typealias Action = HomeAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .load:
                state.isLoading = true
                state.dailyFact = localDataClient.loadDailyFact()
                state.discovery = localDataClient.loadDiscoveryFacts()
                state.favorites = Set(persistenceClient.loadFavorites().map { $0.id })
                state.isLoading = false
                return .none
                
            case .dailyLoaded(let fact):
                state.dailyFact = fact
                return .none
                
            case .discoveryLoaded(let facts):
                state.discovery = facts
                return .none
                
            case .next:
                if state.index < state.discovery.count - 1 {
                    state.index += 1
                }
                return .none
                
            case .shuffle:
                state.discovery = state.discovery.shuffled()
                state.index = 0
                return .none
                
            case .save(let fact):
                persistenceClient.saveFavorite(fact)
                state.favorites.insert(fact.id)
                return .none
                
            case .share(let fact):
                // Handle sharing
                return .none
                
            case .markRead(let fact):
                persistenceClient.markRead(fact.id)
                return .none
            }
        }
    }
}

// MARK: - QuizReducer
struct QuizReducer: Reducer {
    typealias State = QuizState
    typealias Action = QuizAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.continuousClock) var clock
    
    private enum QuizCancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start(let mode):
                state.quizMode = mode
                state.mode = .playing
                state.score = 0
                state.streak = 0
                state.i = 0
                state.timeLeft = 15
                state.questions = localDataClient.loadQuizQuestions(mode)
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: QuizCancelID.timer)
                
            case .questionsLoaded(let questions):
                state.questions = questions
                return .none
                
            case .tick:
                if state.timeLeft > 0 {
                    state.timeLeft -= 1
                } else {
                    state.mode = .result
                    return .cancel(id: QuizCancelID.timer)
                }
                return .none
                
            case .answerIndex(let index):
                if let question = state.questions.first(where: { $0.id == state.questions[state.i].id }) {
                    if let correctIndex = question.correctIndex, index == correctIndex {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .answerBool(let answer):
                if let question = state.questions.first(where: { $0.id == state.questions[state.i].id }) {
                    if let correctAnswer = question.correctAnswer, answer == correctAnswer {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .answerText(let text):
                if let question = state.questions.first(where: { $0.id == state.questions[state.i].id }) {
                    if let correctText = question.correctText, text.lowercased() == correctText.lowercased() {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .next:
                if state.i + 1 < state.questions.count {
                    state.i += 1
                    state.timeLeft = 15
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.tick)
                        }
                    }
                    .cancellable(id: QuizCancelID.timer)
                } else {
                    state.mode = .result
                    let result = QuizResult(
                        id: UUID().uuidString,
                        date: Date(),
                        mode: state.quizMode ?? .recap,
                        score: state.score,
                        total: state.questions.count,
                        bestStreak: state.streak
                    )
                    persistenceClient.saveQuizResult(result)
                    state.history.append(result)
                    return .cancel(id: QuizCancelID.timer)
                }
                
            case .nextPlayer:
                // Handle next player in challenge mode
                return .none
                
            case .showHistory:
                state.mode = .history
                return .none
                
            case .backToOverview:
                state.mode = .overview
                return .cancel(id: QuizCancelID.timer)
                
            case .result(let result):
                state.mode = .result
                return .cancel(id: QuizCancelID.timer)
                
            case .challengeCompleted(let mode, let result):
                state.mode = .result
                return .cancel(id: QuizCancelID.timer)
            }
        }
    }
}

// MARK: - FavoritesReducer
struct FavoritesReducer: Reducer {
    typealias State = FavoritesState
    typealias Action = FavoritesAction
    
    @Dependency(\.persistenceClient) var persistenceClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load, .reload:
                state.items = persistenceClient.loadFavorites()
                return .none
                
            case .setQuery(let query):
                state.query = query
                return .none
                
            case .setCategory(let category):
                state.category = category
                return .none
                
            case .setViewMode(let mode):
                state.viewMode = mode
                return .none
                
            case .remove(let fact):
                persistenceClient.removeFavorite(fact.id)
                state.items.removeAll { $0.id == fact.id }
                return .none
            }
        }
    }
}

// MARK: - ProfileReducer
struct ProfileReducer: Reducer {
    typealias State = ProfileState
    typealias Action = ProfileAction
    
    @Dependency(\.persistenceClient) var persistenceClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                // Load user stats and settings
                state.settings = persistenceClient.loadUserSettings()
                state.stats = persistenceClient.loadUserStats()
                return .none
                
            case .toggleDailyFact(let enabled):
                state.settings.dailyFactNotifications = enabled
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .toggleQuizReminder(let enabled):
                state.settings.quizReminders = enabled
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .setTheme(let theme):
                state.settings.theme = theme
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .setLanguage(let language):
                state.settings.language = language
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .setDisplayName(let name):
                state.settings.displayName = name.isEmpty ? "Gäst" : name
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .setAvatar(let avatarData):
                state.avatarData = avatarData
                if let data = try? JSONEncoder().encode(avatarData) {
                    UserDefaults.standard.set(data, forKey: "avatarData")
                }
                return .none
                
            case .updateStreak:
                // Update streak logic
                return .none
                
            case .acknowledgeLevelUp:
                state.leveledUp = false
                return .none
                
            case .acknowledgeChallengeComplete:
                state.challengeCompleted = false
                return .none
            }
        }
    }
}

// MARK: - FriendsReducer
struct FriendsReducer: Reducer {
    typealias State = FriendsState
    typealias Action = FriendsAction
    
    @Dependency(\.gameCenterClient) var gameCenterClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                state.friends = generateSampleFriends()
                state.pendingRequests = generateSamplePendingRequests()
                state.sentRequests = generateSampleSentRequests()
                state.isLoading = false
                return .none
                
            case .addFriend(let name):
                let newFriend = Friend(name: name, avatar: "👤", level: 1, isOnline: false)
                state.friends.append(newFriend)
                state.newFriendName = ""
                state.showingAddFriend = false
                return .none
                
            case .acceptRequest(let id):
                if let request = state.pendingRequests.first(where: { $0.id == id }) {
                    state.pendingRequests.removeAll { $0.id == id }
                    state.friends.append(request)
                }
                return .none
                
            case .declineRequest(let id):
                state.pendingRequests.removeAll { $0.id == id }
                return .none
                
            case .removeFriend(let id):
                state.friends.removeAll { $0.id == id }
                return .none
                
            case .challengeFriend(let id):
                state.pendingChallenges.append(id)
                return .none
                
            case .setShowingAddFriend(let showing):
                state.showingAddFriend = showing
                return .none
                
            case .setNewFriendName(let name):
                state.newFriendName = name
                return .none
                
            case .startQuizWithFriend(let friendId):
                return .none
                
            case .quickMatch:
                state.isFindingOpponent = true
                return .run { send in
                    do {
                        let isAuthenticated = try await gameCenterClient.authenticate()
                        if isAuthenticated {
                            let opponent = try await gameCenterClient.findRandomOpponent()
                            await send(.opponentFound(opponent))
                        } else {
                            let opponent = Opponent(name: "Random Player", avatar: "🎲", level: Int.random(in: 3...8))
                            await send(.opponentFound(opponent))
                        }
                    } catch {
                        print("Failed to find opponent: \(error)")
                    }
                }
                
            case .opponentFound(let opponent):
                state.isFindingOpponent = false
                let match = Match(opponent: opponent, result: MatchResult(playerScore: 0, opponentScore: 0, isWinner: false), date: Date())
                state.currentMatch = match
                return .send(.matchStarted(match))
                
            case .matchStarted(let match):
                return .none
                
            case .matchCompleted(let result):
                state.matchResult = result
                state.showingMatchResult = true
                state.currentMatch = nil
                return .none
            }
        }
    }
    
    private func generateSampleFriends() -> [Friend] {
        return [
            Friend(name: "Anna", avatar: "👩", level: 5, isOnline: true),
            Friend(name: "Erik", avatar: "👨", level: 3, isOnline: false),
            Friend(name: "Maria", avatar: "👩‍🦱", level: 7, isOnline: true)
        ]
    }
    
    private func generateSamplePendingRequests() -> [Friend] {
        return [
            Friend(name: "Lars", avatar: "👨‍🦳", level: 4, isOnline: false)
        ]
    }
    
    private func generateSampleSentRequests() -> [Friend] {
        return [
            Friend(name: "Sofia", avatar: "👩‍🦰", level: 6, isOnline: true)
        ]
    }
}

// MARK: - ChallengesReducer
struct ChallengesReducer: Reducer {
    typealias State = ChallengesState
    typealias Action = ChallengesAction
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.dailyChallenges = generateDailyChallenges()
                state.weeklyChallenges = generateWeeklyChallenges()
                return .none
                
            case .markComplete(let id):
                if let index = state.dailyChallenges.firstIndex(where: { $0.id == id }) {
                    state.dailyChallenges[index].isCompleted = true
                    state.recentlyCompletedChallenge = state.dailyChallenges[index]
                    state.challengeCompleted = true
                }
                if let index = state.weeklyChallenges.firstIndex(where: { $0.id == id }) {
                    state.weeklyChallenges[index].isCompleted = true
                    state.recentlyCompletedChallenge = state.weeklyChallenges[index]
                    state.challengeCompleted = true
                }
                return .none
                
            case .incrementProgress(let id, let amount):
                if let index = state.dailyChallenges.firstIndex(where: { $0.id == id }) {
                    state.dailyChallenges[index].progress += amount
                    if state.dailyChallenges[index].progress >= state.dailyChallenges[index].target {
                        state.dailyChallenges[index].isCompleted = true
                        state.recentlyCompletedChallenge = state.dailyChallenges[index]
                        state.challengeCompleted = true
                    }
                }
                if let index = state.weeklyChallenges.firstIndex(where: { $0.id == id }) {
                    state.weeklyChallenges[index].progress += amount
                    if state.weeklyChallenges[index].progress >= state.weeklyChallenges[index].target {
                        state.weeklyChallenges[index].isCompleted = true
                        state.recentlyCompletedChallenge = state.weeklyChallenges[index]
                        state.challengeCompleted = true
                    }
                }
                return .none
                
            case .resetDailyChallenges:
                state.dailyChallenges = generateDailyChallenges()
                return .none
                
            case .resetWeeklyChallenges:
                state.weeklyChallenges = generateWeeklyChallenges()
                return .none
                
            case .acknowledgeChallengeComplete:
                state.challengeCompleted = false
                return .none
            }
        }
    }
    
    private func generateDailyChallenges() -> [Challenge] {
        return [
            Challenge(description: "Läs 5 fakta idag", target: 5, progress: 0, isCompleted: false, isDaily: true, reward: 25),
            Challenge(description: "Genomför ett quiz idag", target: 1, progress: 0, isCompleted: false, isDaily: true, reward: 50),
            Challenge(description: "Håll din streak vid liv", target: 1, progress: 0, isCompleted: false, isDaily: true, reward: 15)
        ]
    }
    
    private func generateWeeklyChallenges() -> [Challenge] {
        return [
            Challenge(description: "Läs 30 fakta denna vecka", target: 30, progress: 0, isCompleted: false, isDaily: false, reward: 100),
            Challenge(description: "Genomför 5 quiz denna vecka", target: 5, progress: 0, isCompleted: false, isDaily: false, reward: 200),
            Challenge(description: "Håll en 7-dagars streak", target: 7, progress: 0, isCompleted: false, isDaily: false, reward: 150)
        ]
    }
}

// MARK: - LevelSystem
struct LevelSystem {
    static let xpPerFactRead = 10
    static let xpPerQuizCompletion = 25
    static let xpPerStreakDay = 5
    static let xpPerBadgeUnlocked = 50
    
    static func level(for xp: Int) -> Int {
        return max(1, xp / 100)
    }
    
    static func xpForLevel(_ level: Int) -> Int {
        return level * 100
    }
    
    static func xpProgress(for xp: Int) -> Int {
        let currentLevel = level(for: xp)
        let xpForCurrentLevel = xpForLevel(currentLevel)
        return xp - xpForCurrentLevel
    }
    
    static func xpForNextLevel(for xp: Int) -> Int {
        let currentLevel = level(for: xp)
        let xpForNextLevel = xpForLevel(currentLevel + 1)
        return xpForNextLevel - xp
    }
    
    static func levelIcon(_ level: Int) -> String {
        switch level {
        case 1..<5: return "leaf.fill"
        case 5..<10: return "star.fill"
        case 10..<20: return "bolt.fill"
        case 20..<50: return "crown.fill"
        default: return "sparkles"
        }
    }
    
    static func levelColor(_ level: Int) -> Color {
        switch level {
        case 1..<5: return .green
        case 5..<10: return .yellow
        case 10..<20: return .orange
        case 20..<50: return .purple
        default: return .blue
        }
    }
    
    static func levelTitle(_ level: Int) -> String {
        switch level {
        case 1..<5: return "Nyfiken Nybörjare"
        case 5..<10: return "Faktautforskare"
        case 10..<20: return "Kunskapsmästare"
        case 20..<50: return "Visdomens Väktare"
        default: return "Legendarisk Lärd"
        }
    }
}

// MARK: - LeaderboardIdentifier
struct LeaderboardIdentifier {
    static let quizScore = "quiz_score"
    static let totalXP = "total_xp"
    static let streak = "streak"
}