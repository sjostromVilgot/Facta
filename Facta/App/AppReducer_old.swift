import Foundation
import ComposableArchitecture

// This project uses The Composable Architecture (TCA) for state management and feature structure.
// TCA provides a clear structure for state management, facilitates testing, and makes it easy to build the app modularly.
// Each feature defines State, Action, and Reducer, and uses TCA's dependency injection for clients.

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
            case .onboarding(.finish):
                state.onboardingComplete = true
                UserDefaults.standard.set(true, forKey: "facta-onboarding-complete")
                return .none
                
            case .setOnboardingComplete(let complete):
                state.onboardingComplete = complete
                UserDefaults.standard.set(complete, forKey: "facta-onboarding-complete")
                return .none
                
            case .onboarding, .home, .quiz, .favorites, .profile, .friends:
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
                
            case .toggleQuizReminder(let enabled):
                state.quizReminderEnabled = enabled
                return .none
                
            case .finish:
                state.isComplete = true
                UserDefaults.standard.set(true, forKey: "facta-onboarding-complete")
                UserDefaults.standard.set(state.dailyFactEnabled, forKey: "daily-fact-enabled")
                UserDefaults.standard.set(state.quizReminderEnabled, forKey: "quiz-reminders")
                
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
                
                if state.notificationsEnabled && state.quizReminderEnabled {
                    // Schedule quiz reminder at 18:00
                    let calendar = Calendar.current
                    var dateComponents = DateComponents()
                    dateComponents.hour = 18
                    dateComponents.minute = 0
                    
                    if let scheduledTime = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
                        return .run { _ in
                            try await notificationClient.scheduleQuizReminder(scheduledTime)
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
    @Dependency(\.gameCenterClient) var gameCenterClient
    
    private enum QuizCancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start(let mode):
                state.mode = .playing
                state.quizMode = mode
                state.score = 0
                state.streak = 0
                state.i = 0
                
                // Initialize challenge mode
                if mode == .challenge {
                    state.challengeStage = .player1
                    state.playerOneScore = 0
                    state.playerTwoScore = 0
                } else {
                    state.challengeStage = nil
                }
                
                // Set timer based on mode
                switch mode {
                case .trueFalse:
                    state.timeLeft = 12
                case .blitz:
                    state.timeLeft = 60  // 60 seconds for blitz mode
                case .challenge:
                    state.timeLeft = 15  // Use standard timer for challenges
                default:
                    state.timeLeft = 15
                }
                
                return .run { send in
                    // For challenge mode, use recap questions
                    let questionMode = mode == .challenge ? .recap : mode
                    let questions = localDataClient.loadQuizQuestions(questionMode)
                    await send(.questionsLoaded(questions))
                    
                    // Start timer with cancellation ID
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: QuizCancelID.timer)
                
            case .questionsLoaded(let questions):
                state.questions = questions
                return .none
                
            case .tick:
                // Only tick if in playing mode and not showing explanation
                guard state.mode == .playing else { return .none }
                
                state.timeLeft = max(0, state.timeLeft - 1)
                
                // Handle time up based on mode
                if state.timeLeft == 0 {
                    if state.quizMode == .blitz {
                        // For blitz mode, end the quiz when time runs out
                        let result = QuizResult(
                            id: UUID().uuidString,
                            date: Date(),
                            mode: state.quizMode ?? .blitz,
                            score: state.score,
                            total: state.i, // Total questions attempted
                            bestStreak: state.streak
                        )
                        state.history.append(result)
                        persistenceClient.saveQuizResult(result)
                        state.mode = .result
                        return .cancel(id: QuizCancelID.timer)
                    } else if state.i < state.questions.count {
                        // For other modes, mark current question as wrong due to timeout
                        state.streak = 0 // Reset streak on timeout
                        return .cancel(id: QuizCancelID.timer) // Stop timer until next question
                    }
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
                // Cancel timer when answer is given
                return .cancel(id: QuizCancelID.timer)
                
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
                // Cancel timer when answer is given
                return .cancel(id: QuizCancelID.timer)
                
            case .answerText(let text):
                if state.i < state.questions.count {
                    let question = state.questions[state.i]
                    let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    let correctText = question.correctText?.lowercased() ?? ""
                    let isCorrect = trimmedText == correctText
                    
                    if isCorrect {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                // Cancel timer when answer is given
                return .cancel(id: QuizCancelID.timer)
                
            case .next:
                if state.i + 1 < state.questions.count {
                    state.i += 1
                    
                    // Only reset timer for non-blitz modes
                    if state.quizMode != .blitz {
                        state.timeLeft = state.quizMode == .trueFalse ? 12 : 15
                        
                        // Restart timer for next question
                        return .run { send in
                            for await _ in clock.timer(interval: .seconds(1)) {
                                await send(.tick)
                            }
                        }
                        .cancellable(id: QuizCancelID.timer)
                    }
                } else {
                    // Handle challenge mode completion
                    if state.quizMode == .challenge {
                        if state.challengeStage == .player1 {
                            // Player 1 finished, switch to Player 2
                            state.playerOneScore = state.score
                            state.challengeStage = .player2
                            state.i = 0
                            state.score = 0
                            state.streak = 0
                            state.timeLeft = 15
                            return .none
                        } else if state.challengeStage == .player2 {
                            // Player 2 finished, show results
                            state.playerTwoScore = state.score
                            state.challengeStage = .finished
                            state.mode = .result
                            return .none
                        }
                    } else {
                        // Regular quiz complete - create result
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
                        
                        // Handle challenge completion and rewards
                        if let mode = state.quizMode, mode == .daily || mode == .weekly {
                            return .run { send in
                                await send(.challengeCompleted(mode, result))
                            }
                        }
                        
                        state.mode = .result
                        return .cancel(id: QuizCancelID.timer)
                    }
                }
                return .none
                
            case .challengeCompleted(let mode, let result):
                // Mark challenge as completed
                let today = Calendar.current.startOfDay(for: Date())
                let key = mode == .daily ? "daily-challenge-\(today.timeIntervalSince1970)" : "weekly-challenge-\(Calendar.current.component(.weekOfYear, from: today))"
                UserDefaults.standard.set(true, forKey: key)
                
                // Calculate bonus XP
                let bonusXP = mode == .daily ? 50 : 200
                let perfectBonus = result.score == result.total ? (mode == .daily ? 25 : 100) : 0
                let totalBonus = bonusXP + perfectBonus
                
                // Save bonus XP to persistence
                let currentXP = UserDefaults.standard.integer(forKey: "bonus-xp")
                UserDefaults.standard.set(currentXP + totalBonus, forKey: "bonus-xp")
                
                // Submit score to Game Center
                let percentage = Int((Double(result.score) / Double(result.total)) * 100)
                return .run { send in
                    do {
                        try await gameCenterClient.submitScore(percentage, LeaderboardIdentifier.quizScore)
                    } catch {
                        // Silently fail - Game Center submission is optional
                        print("Failed to submit score to Game Center: \(error)")
                    }
                }
                
                state.mode = .result
                return .none
                
            case .showHistory:
                state.mode = .history
                return .none
                
            case .backToOverview:
                state.mode = .overview
                return .cancel(id: QuizCancelID.timer)
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
                
                // Load and update streak data with improved logic
                var streakData = persistenceClient.loadStreakData()
                let today = Calendar.current.startOfDay(for: Date())
                let lastActiveDate = Calendar.current.startOfDay(for: streakData.lastActiveDate)
                
                // Calculate current streak with improved logic
                let daysDifference = Calendar.current.dateComponents([.day], from: lastActiveDate, to: today).day ?? 0
                
                if daysDifference == 0 {
                    // Same day - streak continues, no change needed
                } else if daysDifference == 1 {
                    // Next consecutive day - increment streak
                    streakData.currentStreak += 1
                    streakData.longestStreak = max(streakData.longestStreak, streakData.currentStreak)
                    if streakData.streakStartDate == nil {
                        streakData.streakStartDate = lastActiveDate
                    }
                } else if daysDifference > 1 {
                    // Gap in usage - reset streak to 1 for today
                    streakData.currentStreak = 1
                    streakData.streakStartDate = today
                } else {
                    // First time user - start streak
                    streakData.currentStreak = 1
                    streakData.streakStartDate = today
                }
                
                // Update last active date
                streakData.lastActiveDate = Date()
                persistenceClient.saveStreakData(streakData)
                
                let currentStreak = streakData.currentStreak
                
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
                
                // Calculate XP based on activities
                let xpFromFacts = totalFactsRead * LevelSystem.xpPerFactRead
                let xpFromQuizzes = totalQuizzes * LevelSystem.xpPerQuizCompletion
                let xpFromStreak = currentStreak * LevelSystem.xpPerStreakDay
                let bonusXP = UserDefaults.standard.integer(forKey: "bonus-xp")
                
                // Calculate daily login reward
                let todayString = DateFormatter.dateOnly.string(from: Date())
                let dailyRewardXP = calculateDailyReward(streakData: streakData, today: todayString)
                
                // Calculate streak milestone bonuses
                let streakMilestoneXP = calculateStreakMilestoneBonus(streakData: streakData, currentStreak: currentStreak)
                
                let totalXP = xpFromFacts + xpFromQuizzes + xpFromStreak + bonusXP + dailyRewardXP + streakMilestoneXP
                
                // Calculate level
                let newLevel = LevelSystem.level(for: totalXP)
                let previousLevel = state.stats.level
                let hasLeveledUp = newLevel > previousLevel
                
                // Set leveled up flag if user leveled up
                if hasLeveledUp {
                    state.leveledUp = true
                }
                
                state.stats = UserStats(
                    streakDays: currentStreak,
                    totalFactsRead: totalFactsRead,
                    totalQuizzes: totalQuizzes,
                    avgQuizScore: avgQuizScore,
                    bestQuizStreak: bestQuizStreak,
                    badgesUnlocked: 0, // Will be calculated below
                    favoriteCategory: favoriteCategory,
                    joinDate: joinDate,
                    currentXP: totalXP,
                    level: newLevel,
                    previousLevel: previousLevel,
                    hasLeveledUp: hasLeveledUp
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
                    // Schedule quiz reminder at 18:00
                    var dateComponents = DateComponents()
                    dateComponents.hour = 18
                    dateComponents.minute = 0
                    if let scheduledTime = Calendar.current.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) {
                        return .run { _ in try await notificationClient.scheduleQuizReminder(scheduledTime) }
                    }
                } else {
                    // Cancel quiz reminders
                    return .run { _ in try await notificationClient.cancelQuizReminder() }
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
                
            case .setDisplayName(let name):
                state.settings.displayName = name.isEmpty ? "Gäst" : name
                persistenceClient.saveUserSettings(state.settings)
                return .none
                
            case .setAvatar(let avatarData):
                // Update avatar data in settings
                // For now, we'll store the avatar type and data in UserDefaults
                if let avatarData = try? JSONEncoder().encode(avatarData) {
                    UserDefaults.standard.set(avatarData, forKey: "avatarData")
                }
                return .none
                
            case .updateStreak:
                // Update streak when user reads daily fact
                var streakData = persistenceClient.loadStreakData()
                let today = Calendar.current.startOfDay(for: Date())
                let lastActiveDate = Calendar.current.startOfDay(for: streakData.lastActiveDate)
                
                let daysDifference = Calendar.current.dateComponents([.day], from: lastActiveDate, to: today).day ?? 0
                
                if daysDifference == 0 {
                    // Same day - no change needed
                } else if daysDifference == 1 {
                    // Next consecutive day - increment streak
                    streakData.currentStreak += 1
                    streakData.longestStreak = max(streakData.longestStreak, streakData.currentStreak)
                    if streakData.streakStartDate == nil {
                        streakData.streakStartDate = lastActiveDate
                    }
                } else if daysDifference > 1 {
                    // Gap in usage - reset streak to 1 for today
                    streakData.currentStreak = 1
                    streakData.streakStartDate = today
                } else {
                    // First time user - start streak
                    streakData.currentStreak = 1
                    streakData.streakStartDate = today
                }
                
                // Update last active date
                streakData.lastActiveDate = Date()
                persistenceClient.saveStreakData(streakData)
                
                // Update stats
                state.stats.streakDays = streakData.currentStreak
                
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

    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                // In a real app, this would load friends from a server
                // For now, we use sample data
                state.isLoading = false
                return .none
                
            case .addFriend(let name):
                let newFriend = Friend(name: name, avatar: "👤", level: 1, isOnline: false)
                state.friends.append(newFriend)
                state.newFriendName = ""
                state.showingAddFriend = false
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
                // This will be handled by the parent reducer to navigate to quiz
                return .none
                
            case .quickMatch:
                state.isFindingOpponent = true
                return .run { send in
                    do {
                        // Authenticate with Game Center first
                        let isAuthenticated = try await gameCenterClient.authenticate()
                        if isAuthenticated {
                            // Find a random opponent
                            let opponent = try await gameCenterClient.findRandomOpponent()
                            await send(.opponentFound(opponent))
                        } else {
                            // Fallback to simulated opponent if not authenticated
                            let opponent = Opponent(
                                name: "Random Player",
                                avatar: "🎲",
                                level: Int.random(in: 3...8)
                            )
                            await send(.opponentFound(opponent))
                        }
                    } catch {
                        // Handle error - could show alert or fallback
                        print("Quick match error: \(error)")
                    }
                }
                
            case .opponentFound(let opponent):
                state.isFindingOpponent = false
                return .run { send in
                    do {
                        let match = try await gameCenterClient.startMatch(opponent)
                        await send(.matchStarted(match))
                    } catch {
                        print("Failed to start match: \(error)")
                    }
                }
                
            case .matchStarted(let match):
                state.currentMatch = match
                // Navigate to quiz with match context
                return .send(.startQuizWithFriend(UUID(uuidString: match.opponent.id) ?? UUID()))
                
            case .matchCompleted(let result):
                state.matchResult = result
                state.showingMatchResult = true
                state.currentMatch = nil
                return .none
            }
        }
    }
}

// MARK: - Streak Helper Functions
extension DateFormatter {
    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

func calculateDailyReward(streakData: StreakData, today: String) -> Int {
    // Check if daily reward was already claimed today
    if streakData.dailyRewardsClaimed.contains(today) {
        return 0
    }
    
    // Base daily reward: 10 XP
    let baseReward = 10
    
    // Streak bonus: +2 XP per streak day (max +20 XP)
    let streakBonus = min(streakData.currentStreak * 2, 20)
    
    return baseReward + streakBonus
}

func calculateStreakMilestoneBonus(streakData: StreakData, currentStreak: Int) -> Int {
    let milestones = [3, 7, 14, 30, 50, 100] // Days
    var totalBonus = 0
    
    for milestone in milestones {
        if currentStreak >= milestone && !streakData.streakMilestones.contains(milestone) {
            // Award milestone bonus
            let bonus = milestone * 5 // 5 XP per milestone day
            totalBonus += bonus
            
            // Mark milestone as rewarded (this would be saved in a real implementation)
            // For now, we'll just calculate the bonus
        }
    }
    
    return totalBonus
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

// MARK: - FriendsReducer
struct FriendsReducer: Reducer {
    typealias State = FriendsState
    typealias Action = FriendsAction
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                // Simulate loading friends
                state.friends = generateSampleFriends()
                state.pendingRequests = generateSamplePendingRequests()
                state.sentRequests = generateSampleSentRequests()
                state.isLoading = false
                return .none
                
            case .addFriend(let name):
                // Add friend logic
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
                // Challenge friend logic
                return .none
                
            case .matchCompleted(let match):
                // Handle match completion
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
}