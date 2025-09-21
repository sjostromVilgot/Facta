import Foundation
import ComposableArchitecture

// MARK: - QuizReducer
struct QuizReducer: Reducer {
    typealias State = QuizState
    typealias Action = QuizAction
    
    @Dependency(\.localDataClient) var localDataClient
    @Dependency(\.persistenceClient) var persistenceClient
    @Dependency(\.continuousClock) var clock
    
    private enum QuizCancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start(let mode):
                state.quizMode = mode
                state.mode = .playing
                state.score = 0
                state.streak = 0
                state.i = 0
                state.timeLeft = 15
                state.questions = localDataClient.loadQuizQuestions(mode)
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.tick)
                    }
                }
                .cancellable(id: QuizCancelID.timer)
                
            case .tick:
                if state.timeLeft > 0 {
                    state.timeLeft -= 1
                } else {
                    state.mode = .result
                    return .cancel(id: QuizCancelID.timer)
                }
                return .none
                
            case .answerIndex(let index):
                if let question = state.questions.first(where: { $0.id == state.questions[state.i].id }) {
                    if index == question.correctIndex {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .answerBool(let answer):
                if let question = state.questions.first(where: { $0.id == state.questions[state.i].id }) {
                    if answer == question.correctAnswer {
                        state.score += 1
                        state.streak += 1
                    } else {
                        state.streak = 0
                    }
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .next:
                if state.i + 1 < state.questions.count {
                    state.i += 1
                    state.timeLeft = 15
                    return .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.tick)
                        }
                    }
                    .cancellable(id: QuizCancelID.timer)
                } else {
                    state.mode = .result
                    let result = QuizResult(
                        id: UUID().uuidString,
                        date: Date(),
                        mode: state.quizMode ?? .recap,
                        score: state.score,
                        total: state.questions.count,
                        bestStreak: state.streak
                    )
                    persistenceClient.saveQuizResult(result)
                    state.history.append(result)
                    return .cancel(id: QuizCancelID.timer)
                }
                
            case .backToOverview:
                state.mode = .overview
                return .cancel(id: QuizCancelID.timer)
                
            case .questionsLoaded(let questions):
                state.questions = questions
                return .none
                
            case .answerIndex(let index):
                guard state.i < state.questions.count else { return .none }
                let question = state.questions[state.i]
                if let correctIndex = question.correctIndex, index == correctIndex {
                    state.score += 1
                    state.streak += 1
                } else {
                    state.streak = 0
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .answerBool(let answer):
                guard state.i < state.questions.count else { return .none }
                let question = state.questions[state.i]
                if let correctAnswer = question.correctAnswer, answer == correctAnswer {
                    state.score += 1
                    state.streak += 1
                } else {
                    state.streak = 0
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .answerText(let text):
                guard state.i < state.questions.count else { return .none }
                let question = state.questions[state.i]
                if let correctText = question.correctText, text.lowercased() == correctText.lowercased() {
                    state.score += 1
                    state.streak += 1
                } else {
                    state.streak = 0
                }
                return .cancel(id: QuizCancelID.timer)
                
            case .nextPlayer:
                // Handle next player in challenge mode
                if state.quizMode == .challenge && state.challengeStage == .player1 {
                    state.playerOneScore = state.score
                    state.challengeStage = .player2
                    state.i = 0
                    state.score = 0
                    state.streak = 0
                    state.timeLeft = 15
                }
                return .none
                
            case .showHistory:
                state.mode = .history
                return .none
                
            case .result(let result):
                state.mode = .result
                return .cancel(id: QuizCancelID.timer)
                
            case .challengeCompleted(let mode, let result):
                state.mode = .result
                return .cancel(id: QuizCancelID.timer)
            }
        }
    }
}
