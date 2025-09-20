import Foundation
import ComposableArchitecture

struct AppEnvironment {
    var localData: LocalDataClient
    var persistence: PersistenceClient
    var notifications: NotificationClient
    var clock: any Clock<Duration>
}

struct AppReducer: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.notificationClient) var notificationClient
    
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
        
        Reduce { state, action in
            switch action {
            case .onboarding(.finish):
                state.onboardingComplete = true
                UserDefaults.standard.set(true, forKey: "facta-onboarding-complete")
                return .none
                
            case .setOnboardingComplete(let complete):
                state.onboardingComplete = complete
                UserDefaults.standard.set(complete, forKey: "facta-onboarding-complete")
                return .none
                
            case .onboarding, .home, .quiz, .favorites, .profile:
                return .none
            }
        }
    }
}

// MARK: - Feature Reducers

struct OnboardingReducer: Reducer {
    typealias State = OnboardingState
    typealias Action = OnboardingAction
    
    @Dependency(\.notificationClient) var notificationClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextStep:
                state.currentStep = min(state.currentStep + 1, 3)
                return .none
                
                    case .getStartedTapped:
                        state.currentStep = 4
                        return .run { send in
                            do {
                                let granted = try await notificationClient.requestAuthorization()
                                await send(.notificationPermissionResponse(granted))
                            } catch {
                                await send(.notificationPermissionResponse(false))
                            }
                        }
                
            case .notificationPermissionResponse(let granted):
                state.notificationsEnabled = granted
                return .none
                
            case .toggleDailyFact(let enabled):
                state.dailyFactEnabled = enabled
                return .none
                
            case .finish:
                state.isComplete = true
                UserDefaults.standard.set(true, forKey: "facta-onboarding-complete")
                UserDefaults.standard.set(state.dailyFactEnabled, forKey: "daily-fact-enabled")
                
                if state.notificationsEnabled && state.dailyFactEnabled {
                    // Schedule daily notification at 09:00
                    let calendar = Calendar.current
                    var dateComponents = DateComponents()
                    dateComponents.hour = 9
                    dateComponents.minute = 0
                    
                    if let scheduledTime = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
                        return .run { _ in
                            try await notificationClient.scheduleDailyReminder(scheduledTime)
                        }
                    }
                }
                
                return .send(.finish)
            }
        }
    }
}

struct HomeReducer: Reducer {
    typealias State = HomeState
    typealias Action = HomeAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    let daily = localDataClient.loadDailyFact()
                    let discovery = localDataClient.loadDiscoveryFacts()
                    
                    await send(.dailyLoaded(daily))
                    await send(.discoveryLoaded(discovery))
                }
                
            case .dailyLoaded(let fact):
                state.dailyFact = fact
                state.isLoading = false
                return .none
                
            case .discoveryLoaded(let facts):
                state.discovery = facts
                state.index = 0
                state.isLoading = false
                return .none
                
            case .save(let fact):
                if !state.favorites.contains(fact.id) {
                    state.favorites.insert(fact.id)
                    persistenceClient.saveFavorite(fact)
                }
                return .none
                
            case .next:
                state.index = min(state.index + 1, state.discovery.count - 1)
                return .none
                
            case .shuffle:
                state.discovery.shuffle()
                state.index = 0
                return .none
                
            case .share(let fact):
                // Share functionality handled in FactCardView
                return .none
                
            case .markRead(let fact):
                persistenceClient.markRead(fact.id)
                return .none
            }
        }
    }
}

struct QuizReducer: Reducer {
    typealias State = QuizState
    typealias Action = QuizAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.continuousClock) var clock
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start(let mode):
                state.mode = .playing
                state.quizMode = mode
                state.score = 0
                state.streak = 0
                state.i = 0
                state.timeLeft = mode == .trueFalse ? 12 : 15
                
                return .run { send in
                    let questions = localDataClient.loadQuizQuestions(mode)
                    await send(.questionsLoaded(questions))
                    
                    // Start timer
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                
            case .questionsLoaded(let questions):
                state.questions = questions
                return .none
                
            case .tick:
                state.timeLeft = max(0, state.timeLeft - 1)
                if state.timeLeft == 0 && state.i < state.questions.count {
                    return .send(.answerIndex(nil))
                }
                return .none
                
            case .answerIndex(let index):
                if state.i < state.questions.count {
                    let question = state.questions[state.i]
                    let isCorrect = index == question.correctIndex
                    
                    if isCorrect {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .none
                
            case .answerBool(let answer):
                if state.i < state.questions.count {
                    let question = state.questions[state.i]
                    let isCorrect = answer == question.correctAnswer
                    
                    if isCorrect {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .none
                
            case .next:
                if state.i + 1 < state.questions.count {
                    state.i += 1
                    state.timeLeft = state.quizMode == .trueFalse ? 12 : 15
                } else {
                    // Quiz complete - create result
                    let result = QuizResult(
                        id: UUID().uuidString,
                        date: Date(),
                        mode: state.quizMode ?? .recap,
                        score: state.score,
                        total: state.questions.count,
                        bestStreak: state.streak
                    )
                    state.history.append(result)
                    persistenceClient.saveQuizResult(result)
                    state.mode = .result
                }
                return .none
                
            case .showHistory:
                state.mode = .history
                return .none
                
            case .backToOverview:
                state.mode = .overview
                return .none
            }
        }
    }
}

struct FavoritesReducer: Reducer {
    typealias State = FavoritesState
    typealias Action = FavoritesAction
    
    @Dependency(\.persistenceClient) var persistenceClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .reload:
                state.items = persistenceClient.loadFavorites()
                return .none
                
            case .setQuery(let query):
                state.query = query
                return .none
                
            case .setCategory(let category):
                state.category = category
                return .none
                
            case .setViewMode(let viewMode):
                state.viewMode = viewMode
                return .none
                
            case .remove(let id):
                state.items.removeAll { $0.id == id }
                persistenceClient.removeFavorite(id)
                return .none
                
            case .share(let fact):
                // Share functionality handled in FactCardView
                return .none
            }
        }
    }
}

struct ProfileReducer: Reducer {
    typealias State = ProfileState
    typealias Action = ProfileAction
    
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.notificationClient) var notificationClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                // Load and calculate stats from persistence
                let readFacts = persistenceClient.loadReadFacts()
                let quizHistory = persistenceClient.loadQuizHistory()
                let favorites = persistenceClient.loadFavorites()
                
                // Calculate stats
                let totalFactsRead = readFacts.count
                let totalQuizzes = quizHistory.count
                let avgQuizScore = quizHistory.isEmpty ? 0 : quizHistory.map { $0.score }.reduce(0, +) / quizHistory.count
                let bestQuizStreak = quizHistory.map { $0.bestStreak }.max() ?? 0
                
                // Calculate favorite category
                let categoryCounts = Dictionary(grouping: favorites, by: \.category)
                    .mapValues { $0.count }
                let favoriteCategory = categoryCounts.max(by: { $0.value < $1.value })?.key
                
                // Get or set join date
                let joinDate: Date
                if let savedJoinDate = UserDefaults.standard.object(forKey: "join-date") as? Date {
                    joinDate = savedJoinDate
                } else {
                    joinDate = Date()
                    UserDefaults.standard.set(joinDate, forKey: "join-date")
                }
                
                state.stats = UserStats(
                    streakDays: 0, // TODO: Calculate actual streak
                    totalFactsRead: totalFactsRead,
                    totalQuizzes: totalQuizzes,
                    avgQuizScore: avgQuizScore,
                    bestQuizStreak: bestQuizStreak,
                    badgesUnlocked: 0, // Will be calculated below
                    favoriteCategory: favoriteCategory,
                    joinDate: joinDate
                )
                
                // Generate badges based on stats
                state.badges = generateBadges(from: state.stats)
                state.stats.badgesUnlocked = state.badges.filter { $0.isUnlocked }.count
                
                return .none
                
            case .toggleDailyFact(let enabled):
                state.settings.dailyFactNotifications = enabled
                UserDefaults.standard.set(enabled, forKey: "daily-fact-notifications")
                
                if enabled {
                    // Schedule daily notification at 09:00
                    let calendar = Calendar.current
                    var dateComponents = DateComponents()
                    dateComponents.hour = 9
                    dateComponents.minute = 0
                    
                    if let scheduledTime = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
                        return .run { _ in
                            try await notificationClient.scheduleDailyReminder(scheduledTime)
                        }
                    }
                } else {
                    return .run { _ in
                        try await notificationClient.cancelDailyReminder()
                    }
                }
                
                return .none
                
            case .toggleQuizReminder(let enabled):
                state.settings.quizReminders = enabled
                UserDefaults.standard.set(enabled, forKey: "quiz-reminders")
                
                if enabled {
                    // TODO: Schedule quiz reminders
                } else {
                    // TODO: Cancel quiz reminders
                }
                
                return .none
                
            case .setTheme(let theme):
                state.settings.theme = theme
                UserDefaults.standard.set(theme.rawValue, forKey: "theme")
                return .none
                
            case .setLanguage(let language):
                state.settings.language = language
                UserDefaults.standard.set(language, forKey: "language")
                return .none
            }
        }
    }
    
    private func generateBadges(from stats: UserStats) -> [Badge] {
        return [
            Badge(
                id: "first-fact",
                name: "Första fakta",
                description: "Läs din första fakta",
                icon: "📖",
                color: .blue,
                isUnlocked: stats.totalFactsRead >= 1,
                unlockedDate: stats.totalFactsRead >= 1 ? stats.joinDate : nil
            ),
            Badge(
                id: "fact-reader",
                name: "Fakta-läsare",
                description: "Läs 10 fakta",
                icon: "📚",
                color: .green,
                isUnlocked: stats.totalFactsRead >= 10,
                unlockedDate: nil
            ),
            Badge(
                id: "quiz-master",
                name: "Quiz-mästare",
                description: "Spela 5 quiz",
                icon: "🧠",
                color: .purple,
                isUnlocked: stats.totalQuizzes >= 5,
                unlockedDate: nil
            ),
            Badge(
                id: "perfectionist",
                name: "Perfektionist",
                description: "Få 100% på ett quiz",
                icon: "⭐",
                color: .gold,
                isUnlocked: stats.avgQuizScore >= 100,
                unlockedDate: nil
            ),
            Badge(
                id: "streak-master",
                name: "Streak-mästare",
                description: "Få en streak på 5",
                icon: "🔥",
                color: .red,
                isUnlocked: stats.bestQuizStreak >= 5,
                unlockedDate: nil
            ),
            Badge(
                id: "dedicated",
                name: "Hängiven",
                description: "Läs 50 fakta",
                icon: "💎",
                color: .silver,
                isUnlocked: stats.totalFactsRead >= 50,
                unlockedDate: nil
            ),
            Badge(
                id: "quiz-champion",
                name: "Quiz-mästare",
                description: "Spela 20 quiz",
                icon: "🏆",
                color: .gold,
                isUnlocked: stats.totalQuizzes >= 20,
                unlockedDate: nil
            ),
            Badge(
                id: "knowledge-seeker",
                name: "Kunskapssökare",
                description: "Läs 100 fakta",
                icon: "🎓",
                color: .bronze,
                isUnlocked: stats.totalFactsRead >= 100,
                unlockedDate: nil
            )
        ]
    }
}