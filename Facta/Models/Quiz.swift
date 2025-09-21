import Foundation

enum QuizMode: String, Codable {
    case recap
    case trueFalse
    case image
    case fillBlank
    case blitz
    case daily
    case weekly
    case challenge
    
    var displayName: String {
        switch self {
        case .recap:
            return "recap-quiz"
        case .trueFalse:
            return "sant/falskt-quiz"
        case .image:
            return "bild-quiz"
        case .fillBlank:
            return "fyll-i-quiz"
        case .blitz:
            return "blixt-quiz"
        case .daily:
            return "daglig utmaning"
        case .weekly:
            return "veckans utmaning"
        case .challenge:
            return "utmana vän"
        }
    }
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let mode: QuizMode
    let question: String
    let options: [String]?      // recap, image
    let correctIndex: Int?      // recap, image
    let correctAnswer: Bool?    // true/false
    let correctText: String?    // fillBlank
    let imageName: String?      // image
    let explanation: String
    let category: String
}

struct QuizResult: Identifiable, Codable, Hashable {
    let id: String
    let date: Date
    let mode: QuizMode
    let score: Int
    let total: Int
    let bestStreak: Int
}