import Foundation

struct Challenge: Identifiable, Equatable, Codable {
    let id: UUID
    let description: String
    let target: Int
    var progress: Int
    var isCompleted: Bool
    let isDaily: Bool
    let rewardXP: Int
    let icon: String
    let color: ChallengeColor
    
    init(
        id: UUID = UUID(),
        description: String,
        target: Int,
        progress: Int = 0,
        isCompleted: Bool = false,
        isDaily: Bool,
        rewardXP: Int,
        icon: String,
        color: ChallengeColor = .blue
    ) {
        self.id = id
        self.description = description
        self.target = target
        self.progress = progress
        self.isCompleted = isCompleted
        self.isDaily = isDaily
        self.rewardXP = rewardXP
        self.icon = icon
        self.color = color
    }
    
    var progressPercentage: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }
    
    var isNearCompletion: Bool {
        return progressPercentage >= 0.8 && !isCompleted
    }
}

enum ChallengeColor: String, CaseIterable, Codable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case red = "red"
    case yellow = "yellow"
    
    var color: Color {
        switch self {
        case .blue:
            return .blue
        case .green:
            return .green
        case .orange:
            return .orange
        case .purple:
            return .purple
        case .red:
            return .red
        case .yellow:
            return .yellow
        }
    }
}

// MARK: - Challenge Generation
extension Challenge {
    static func generateDailyChallenges() -> [Challenge] {
        return [
            Challenge(
                description: "Läs 3 fakta idag",
                target: 3,
                isDaily: true,
                rewardXP: 50,
                icon: "book.fill",
                color: .blue
            ),
            Challenge(
                description: "Genomför ett quiz idag",
                target: 1,
                isDaily: true,
                rewardXP: 75,
                icon: "brain.head.profile",
                color: .green
            ),
            Challenge(
                description: "Spara 2 favoriter idag",
                target: 2,
                isDaily: true,
                rewardXP: 40,
                icon: "heart.fill",
                color: .red
            ),
            Challenge(
                description: "Få 80% rätt på ett quiz",
                target: 1,
                isDaily: true,
                rewardXP: 100,
                icon: "star.fill",
                color: .yellow
            )
        ]
    }
    
    static func generateWeeklyChallenges() -> [Challenge] {
        return [
            Challenge(
                description: "Läs 20 fakta denna vecka",
                target: 20,
                isDaily: false,
                rewardXP: 200,
                icon: "book.circle.fill",
                color: .blue
            ),
            Challenge(
                description: "Genomför 5 quiz denna vecka",
                target: 5,
                isDaily: false,
                rewardXP: 300,
                icon: "brain.head.profile",
                color: .green
            ),
            Challenge(
                description: "Håll en 7-dagars streak",
                target: 7,
                isDaily: false,
                rewardXP: 500,
                icon: "flame.fill",
                color: .orange
            ),
            Challenge(
                description: "Spara 10 favoriter denna vecka",
                target: 10,
                isDaily: false,
                rewardXP: 150,
                icon: "heart.circle.fill",
                color: .red
            ),
            Challenge(
                description: "Få 90% rätt på 3 quiz",
                target: 3,
                isDaily: false,
                rewardXP: 400,
                icon: "star.circle.fill",
                color: .yellow
            )
        ]
    }
}
