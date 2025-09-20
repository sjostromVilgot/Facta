import Foundation

enum QuizMode: String, Codable {
    case recap
    case trueFalse
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let mode: QuizMode
    let question: String
    let options: [String]?      // recap
    let correctIndex: Int?      // recap
    let correctAnswer: Bool?    // true/false
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