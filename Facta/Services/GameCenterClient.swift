import Foundation
import GameKit
import ComposableArchitecture

struct GameCenterClient {
    var authenticate: () async throws -> Bool
    var submitScore: (Int, String) async throws -> Void
    var loadLeaderboard: (String) async throws -> [LeaderboardEntry]
    var loadLocalPlayerScore: (String) async throws -> LeaderboardEntry?
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
        }
    )
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

struct LeaderboardIdentifier {
    static let quizScore = "quiz_score"
    static let totalXP = "total_xp"
    static let streak = "streak"
}