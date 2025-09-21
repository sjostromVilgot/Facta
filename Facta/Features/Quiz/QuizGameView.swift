import SwiftUI
import ComposableArchitecture
import UIKit

struct QuizGameView: View {
    let store: Store<QuizState, QuizAction>
    @State private var selectedAnswer: Int? = nil
    @State private var selectedBool: Bool? = nil
    @State private var textAnswer: String = ""
    @State private var showExplanation = false
    @State private var answerAnimations: [Int: Bool] = [:]
    @State private var answerShake: [Int: Bool] = [:]
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            mainContent(viewStore: viewStore)
        }
    }
    
    private func mainContent(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: 0) {
            topBar(viewStore: viewStore)
            progressBar(viewStore: viewStore)
            timerSection(viewStore: viewStore)
            questionSection(viewStore: viewStore)
            Spacer()
        }
    }
    
    private func topBar(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        HStack {
            Button("Avsluta") {
                viewStore.send(.backToOverview)
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            modeTitle(viewStore: viewStore)
            
            Spacer()
            
            questionCounter(viewStore: viewStore)
        }
        .padding()
        .background(Color.muted)
    }
    
    private func modeTitle(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: 4) {
            Text(quizModeTitle(viewStore.quizMode))
                .font(.headline)
                .foregroundColor(.primary)
            
            if viewStore.quizMode == .challenge {
                Text(challengeStageText(viewStore.challengeStage))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func questionCounter(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Text("Fråga \(viewStore.i + 1) av \(viewStore.questions.count)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    private func progressBar(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Group {
            if viewStore.quizMode != .blitz {
                ProgressView(value: Double(viewStore.i), total: Double(viewStore.questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    .padding(.horizontal)
            }
        }
    }
    
    private func timerSection(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        HStack {
            if viewStore.quizMode == .blitz {
                blitzTimer(viewStore: viewStore)
                Spacer()
                questionsAnswered(viewStore: viewStore)
            } else {
                Spacer()
                regularTimer(viewStore: viewStore)
            }
        }
        .padding()
    }
    
    private func blitzTimer(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: 4) {
            Text("Tid kvar")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(max(0, viewStore.timeLeft))s")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(viewStore.timeLeft <= 10 ? .red : .primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: viewStore.timeLeft)
        }
        .padding()
        .background(timerBackground(timeLeft: viewStore.timeLeft))
    }
    
    private func questionsAnswered(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: 4) {
            Text("Besvarade")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(viewStore.i)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.muted)
        .cornerRadius(UI.corner)
    }
    
    private func regularTimer(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Text("\(max(0, viewStore.timeLeft))s")
            .font(.headline)
            .foregroundColor(viewStore.timeLeft <= 5 ? .red : .primary)
            .padding(.horizontal, UI.Padding.medium)
            .padding(.vertical, UI.Padding.small)
            .background(viewStore.timeLeft <= 5 ? Color.red.opacity(0.1) : Color.muted)
            .cornerRadius(UI.corner)
    }
    
    private func timerBackground(timeLeft: Int) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(timeLeft <= 10 ? Color.red.opacity(0.1) : Color.muted)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(timeLeft <= 10 ? Color.red : Color.clear, lineWidth: 2)
            )
    }
    
    private func questionSection(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Group {
            if viewStore.i < viewStore.questions.count {
                let question = viewStore.questions[viewStore.i]
                questionCard(question: question, viewStore: viewStore)
            }
        }
    }
    
    private func questionCard(question: QuizQuestion, viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.large) {
            questionHeader(question: question)
            answerOptions(question: question, viewStore: viewStore)
            nextButton(viewStore: viewStore)
        }
        .padding()
    }
    
    private func questionHeader(question: QuizQuestion) -> some View {
        VStack(spacing: UI.Spacing.medium) {
            Text(question.category)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, UI.Padding.medium)
                .padding(.vertical, UI.Padding.small)
                .background(Color.muted)
                .cornerRadius(UI.corner)
            
            Text(question.question)
                .font(.title2)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private func answerOptions(question: QuizQuestion, viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Group {
            if question.mode == .recap, let options = question.options {
                multipleChoiceOptions(options: options, question: question, viewStore: viewStore)
            } else if question.mode == .trueFalse {
                trueFalseOptions(question: question, viewStore: viewStore)
            }
        }
    }
    
    private func multipleChoiceOptions(options: [String], question: QuizQuestion, viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.medium) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                answerButton(
                    text: option,
                    isSelected: selectedAnswer == index,
                    action: {
                        selectedAnswer = index
                        let isCorrect = index == question.correctIndex
                        triggerHapticFeedback(isCorrect: isCorrect)
                        showExplanation = true
                    }
                )
            }
        }
    }
    
    private func trueFalseOptions(question: QuizQuestion, viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        HStack(spacing: UI.Spacing.large) {
            answerButton(
                text: "Sant",
                isSelected: selectedBool == true,
                action: {
                    selectedBool = true
                    let isCorrect = question.correctAnswer == true
                    triggerHapticFeedback(isCorrect: isCorrect)
                    showExplanation = true
                }
            )
            
            answerButton(
                text: "Falskt",
                isSelected: selectedBool == false,
                action: {
                    selectedBool = false
                    let isCorrect = question.correctAnswer == false
                    triggerHapticFeedback(isCorrect: isCorrect)
                    showExplanation = true
                }
            )
        }
    }
    
    private func answerButton(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .foregroundColor(isSelected ? .white : .primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.primary : Color.muted)
                .cornerRadius(UI.corner)
        }
        .disabled(showExplanation)
    }
    
    private func nextButton(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        Group {
            if showExplanation {
                Button("Nästa fråga") {
                    selectedAnswer = nil
                    selectedBool = nil
                    textAnswer = ""
                    showExplanation = false
                    viewStore.send(.next)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
    }
    
    private func triggerHapticFeedback(isCorrect: Bool) {
        if isCorrect {
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        } else {
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
        }
    }
    
    private func quizModeTitle(_ mode: QuizMode?) -> String {
        switch mode {
        case .recap:
            return "Recap-quiz"
        case .trueFalse:
            return "Sant/Falskt"
        case .image:
            return "Bild-quiz"
        case .fillBlank:
            return "Fyll i"
        case .blitz:
            return "Blixt-quiz"
        case .daily:
            return "Daglig utmaning"
        case .weekly:
            return "Veckans utmaning"
        case .challenge:
            return "Utmana vän"
        case .none:
            return "Quiz"
        }
    }
    
    private func challengeStageText(_ stage: ChallengeStage?) -> String {
        switch stage {
        case .player1:
            return "Spelare 1"
        case .player2:
            return "Spelare 2"
        case .finished:
            return "Färdig"
        case .none:
            return ""
        }
    }
}
