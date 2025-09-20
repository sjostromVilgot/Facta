import Foundation
import SwiftUI

struct Badge: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let icon: String // emoji eller SF-symbolnamn
    let color: BadgeColor
    var isUnlocked: Bool
    var unlockedDate: Date?
}

enum BadgeColor: String, CaseIterable, Codable {
    case gold = "gold"
    case silver = "silver"
    case bronze = "bronze"
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case red = "red"
    case orange = "orange"
    
    var swiftUIColor: Color {
        switch self {
        case .gold:
            return .yellow
        case .silver:
            return .gray
        case .bronze:
            return .orange
        case .blue:
            return .blue
        case .green:
            return .green
        case .purple:
            return .purple
        case .red:
            return .red
        case .orange:
            return .orange
        }
    }
}