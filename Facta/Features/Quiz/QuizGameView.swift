import SwiftUI
import ComposableArchitecture

struct QuizGameView: View {
    let store: StoreOf<QuizReducer>
    @State private var selectedAnswer: Int? = nil
    @State private var selectedBool: Bool? = nil
    @State private var showExplanation = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button("Avsluta") {
                        viewStore.send(.backToOverview)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(quizModeTitle(viewStore.quizMode))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("Fråga \(viewStore.i + 1) av \(viewStore.questions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.muted)
                
                // Progress Bar
                ProgressView(value: Double(viewStore.i), total: Double(viewStore.questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    .padding(.horizontal)
                
                // Timer
                HStack {
                    Spacer()
                    Text("\(viewStore.timeLeft)s")
                        .font(.headline)
                        .foregroundColor(viewStore.timeLeft <= 5 ? .red : .primary)
                        .padding(.horizontal, UI.Padding.medium)
                        .padding(.vertical, UI.Padding.small)
                        .background(viewStore.timeLeft <= 5 ? Color.red.opacity(0.1) : Color.muted)
                        .cornerRadius(UI.corner)
                }
                .padding()
                
                // Question Card
                if viewStore.i < viewStore.questions.count {
                    let question = viewStore.questions[viewStore.i]
                    
                    VStack(spacing: UI.Spacing.large) {
                        // Category
                        Text(question.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, UI.Padding.medium)
                            .padding(.vertical, UI.Padding.small)
                            .background(Color.muted)
                            .cornerRadius(UI.corner)
                        
                        // Question
                        Text(question.question)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        // Answer Options
                        if question.mode == .recap, let options = question.options {
                            VStack(spacing: UI.Spacing.medium) {
                                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                                    Button(action: {
                                        selectedAnswer = index
                                        viewStore.send(.answerIndex(index))
                                        showExplanation = true
                                    }) {
                                        HStack {
                                            Text("\(Character(UnicodeScalar(65 + index)!))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                                .frame(width: 30, height: 30)
                                                .background(Color.muted)
                                                .cornerRadius(15)
                                            
                                            Text(option)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(selectedAnswer == index ? Color.primary.opacity(0.1) : Color.muted)
                                        .cornerRadius(UI.corner)
                                    }
                                    .disabled(showExplanation)
                                }
                            }
                        } else if question.mode == .trueFalse {
                            HStack(spacing: UI.Spacing.large) {
                                Button(action: {
                                    selectedBool = true
                                    viewStore.send(.answerBool(true))
                                    showExplanation = true
                                }) {
                                    Text("SANT")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedBool == true ? Color.green : Color.primary)
                                        .cornerRadius(UI.corner)
                                }
                                .disabled(showExplanation)
                                
                                Button(action: {
                                    selectedBool = false
                                    viewStore.send(.answerBool(false))
                                    showExplanation = true
                                }) {
                                    Text("FALSKT")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(selectedBool == false ? Color.red : Color.primary)
                                        .cornerRadius(UI.corner)
                                }
                                .disabled(showExplanation)
                            }
                        }
                        
                        // Explanation
                        if showExplanation {
                            VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                                Text("Facit")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if question.mode == .recap {
                                    if let correctIndex = question.correctIndex,
                                       let options = question.options,
                                       correctIndex < options.count {
                                        Text("Rätt svar: \(options[correctIndex])")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                } else {
                                    Text("Rätt svar: \(question.correctAnswer == true ? "SANT" : "FALSKT")")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                
                                Text("Visste du att...")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(question.explanation)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.muted)
                            .cornerRadius(UI.corner)
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Next Button
                if showExplanation {
                    Button("Nästa fråga") {
                        selectedAnswer = nil
                        selectedBool = nil
                        showExplanation = false
                        viewStore.send(.next)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
            }
        }
    }
    
    private func quizModeTitle(_ mode: QuizMode?) -> String {
        switch mode {
        case .recap:
            return "Recap-quiz"
        case .trueFalse:
            return "Sant/Falskt"
        case .none:
            return "Quiz"
        }
    }
}
