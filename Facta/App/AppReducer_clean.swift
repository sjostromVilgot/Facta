import Foundation
import ComposableArchitecture

// This project uses The Composable Architecture (TCA) for state management and feature structure.
// TCA provides a clear structure for state management, facilitates testing, and makes it easy to build the app modularly.
// Each feature defines State, Action, and Reducer, and uses TCA's dependency injection for clients.

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
                
            case .quiz(.result(let result)):
                // Handle quiz result
                return .none
                
            case .profile(.setDisplayName(let name)):
                state.profile.settings.displayName = name.isEmpty ? "Gäst" : name
                persistenceClient.saveUserSettings(state.profile.settings)
                return .none
                
            case .profile(.setAvatar(let avatarData)):
                // Update avatar data in settings
                if let data = try? JSONEncoder().encode(avatarData) {
                    UserDefaults.standard.set(data, forKey: "avatarData")
                }
                return .none
                
            default:
                return .none
            }
        }
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
