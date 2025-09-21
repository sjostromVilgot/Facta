import Foundation

struct StreakData: Codable, Equatable {
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date
    var streakStartDate: Date?
    var dailyRewardsClaimed: Set<String> // Date strings
    var streakMilestones: Set<Int> // Milestone days achieved
    
    static var empty: StreakData {
        StreakData(
            currentStreak: 0,
            longestStreak: 0,
            lastActiveDate: Date(),
            streakStartDate: nil,
            dailyRewardsClaimed: [],
            streakMilestones: []
        )
    }
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDate: Date = Date(),
        streakStartDate: Date? = nil,
        dailyRewardsClaimed: Set<String> = [],
        streakMilestones: Set<Int> = []
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDate = lastActiveDate
        self.streakStartDate = streakStartDate
        self.dailyRewardsClaimed = dailyRewardsClaimed
        self.streakMilestones = streakMilestones
    }
    
    /// Update streak based on current date
    mutating func updateStreak(for date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let lastDay = calendar.startOfDay(for: lastActiveDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        switch daysDifference {
        case 0:
            // Same day - no change
            break
        case 1:
            // Consecutive day - continue streak
            currentStreak += 1
            lastActiveDate = date
            
            // Update longest streak if needed
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
            
            // Add milestone if reached
            if currentStreak % 5 == 0 {
                streakMilestones.insert(currentStreak)
            }
            
        default:
            // Streak broken - start new
            currentStreak = 1
            lastActiveDate = date
            streakStartDate = today
        }
    }
    
    /// Check if daily reward has been claimed
    func hasClaimedDailyReward(for date: Date = Date()) -> Bool {
        let dateString = DateFormatter.dayFormatter.string(from: date)
        return dailyRewardsClaimed.contains(dateString)
    }
    
    /// Claim daily reward
    mutating func claimDailyReward(for date: Date = Date()) {
        let dateString = DateFormatter.dayFormatter.string(from: date)
        dailyRewardsClaimed.insert(dateString)
    }
}

// MARK: - Date Formatter
private extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
