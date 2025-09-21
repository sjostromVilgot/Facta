import Foundation
import SwiftUI

struct LevelSystem {
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
    
    static func levelTitle(_ level: Int) -> String {
        switch level {
        case 1...5:
            return "Fakta-utforskare"
        case 6...10:
            return "Kunskapsjaktare"
        case 11...15:
            return "Vetenskapsentusiast"
        case 16...20:
            return "Fakta-mästare"
        case 21...25:
            return "Kunskapslegende"
        default:
            return "Fakta-legende"
        }
    }
    
    static func levelIcon(_ level: Int) -> String {
        switch level {
        case 1...5:
            return "star.fill"
        case 6...10:
            return "star.circle.fill"
        case 11...15:
            return "crown.fill"
        case 16...20:
            return "trophy.fill"
        case 21...25:
            return "medal.fill"
        default:
            return "diamond.fill"
        }
    }
    
    static func levelColor(_ level: Int) -> Color {
        switch level {
        case 1...5:
            return .blue
        case 6...10:
            return .green
        case 11...15:
            return .orange
        case 16...20:
            return .purple
        case 21...25:
            return .red
        default:
            return .yellow
        }
    }
}