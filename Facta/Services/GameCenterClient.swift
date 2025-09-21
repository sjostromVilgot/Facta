import Foundation
import GameKit
import ComposableArchitecture

struct GameCenterClient {
    var authenticate: () async throws -> Bool
    var submitScore: (Int, String) async throws -> Void
    var loadLeaderboard: (String) async throws -> [LeaderboardEntry]
    var loadLocalPlayerScore: (String) async throws -> LeaderboardEntry?
    var findRandomOpponent: () async throws -> Opponent
    var startMatch: (Opponent) async throws -> Match
}

extension GameCenterClient: DependencyKey {
    static let liveValue = Self(
        authenticate: {
            let localPlayer = GKLocalPlayer.local
            return try await localPlayer.authenticateHandler == nil
        },
        submitScore: { score, leaderboardID in
            let localPlayer = GKLocalPlayer.local
            try await localPlayer.submitScore(score, category: leaderboardID)
        },
        loadLeaderboard: { leaderboardID in
            let leaderboard = GKLeaderboard()
            leaderboard.identifier = leaderboardID
            leaderboard.timeScope = .allTime
            leaderboard.range = NSRange(location: 1, length: 100)
            
            let entries = try await leaderboard.loadEntries(for: .global, timeScope: .allTime)
            return entries.map { entry in
                LeaderboardEntry(
                    playerName: entry.player.displayName,
                    score: entry.score,
                    rank: entry.rank
                )
            }
        },
        loadLocalPlayerScore: { leaderboardID in
            let leaderboard = GKLeaderboard()
            leaderboard.identifier = leaderboardID
            leaderboard.timeScope = .allTime
            
            let entries = try await leaderboard.loadEntries(for: .friends, timeScope: .allTime)
            if let entry = entries.first {
                return LeaderboardEntry(
                    playerName: entry.player.displayName,
                    score: entry.score,
                    rank: entry.rank
                )
            }
            return nil
        },
        findRandomOpponent: {
            // Find a random opponent for quick match
            return Opponent(
                id: UUID(),
                name: "Random Player",
                avatar: "🎲",
                level: Int.random(in: 1...10),
                isOnline: true
            )
        },
        startMatch: { opponent in
            // Start a match with the opponent
            return Match(
                id: UUID(),
                opponent: opponent,
                result: MatchResult(playerScore: 0, opponentScore: 0, isWinner: false),
                date: Date()
            )
        }
    )
    
    static let testValue = Self(
        authenticate: { true },
        submitScore: { _, _ in },
        loadLeaderboard: { _ in [] },
        loadLocalPlayerScore: { _ in nil },
        findRandomOpponent: { 
            Opponent(id: UUID(), name: "Test Player", avatar: "🧪", level: 5, isOnline: true)
        },
        startMatch: { opponent in
            Match(
                id: UUID(),
                opponent: opponent,
                result: MatchResult(playerScore: 0, opponentScore: 0, isWinner: false),
                date: Date()
            )
        }
    )
}

extension DependencyValues {
    var gameCenterClient: GameCenterClient {
        get { self[GameCenterClient.self] }
        set { self[GameCenterClient.self] = newValue }
    }
}

struct LeaderboardEntry: Identifiable, Equatable {
    let id = UUID()
    let playerName: String
    let score: Int
    let rank: Int
}

enum LeaderboardIdentifier {
    static let quizScore = "com.facta.quiz.score"
    static let totalXP = "com.facta.total.xp"
    static let streak = "com.facta.streak"
}