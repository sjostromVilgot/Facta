import SwiftUI
import ComposableArchitecture
import UIKit

struct QuizGameView: View {
    let store: StoreOf<QuizReducer>
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
            questionContent(viewStore: viewStore)
        }
    }
    
    private func topBar(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        HStack {
            Button("Avsluta") {
                viewStore.send(.backToOverview)
            }
            .foregroundColor(.secondary)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(quizModeTitle(viewStore.quizMode))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Challenge stage indicator
                if viewStore.quizMode == .challenge {
                    Text(challengeStageText(viewStore.challengeStage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("Fråga \(viewStore.i + 1) av \(viewStore.questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.muted)
    }
    
    private func questionContent(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: 0) {
                
                // Progress Bar (hidden for blitz mode)
                if viewStore.quizMode != .blitz {
                ProgressView(value: Double(viewStore.i), total: Double(viewStore.questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    .padding(.horizontal)
                }
                
                // Timer
                HStack {
                    if viewStore.quizMode == .blitz {
                        // Blitz mode: show countdown timer prominently
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
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewStore.timeLeft <= 10 ? Color.red.opacity(0.1) : Color.muted)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(viewStore.timeLeft <= 10 ? Color.red : Color.clear, lineWidth: 2)
                                )
                        )
                        
                        Spacer()
                        
                        // Questions answered counter
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
                        .cornerRadius(12)
                    } else {
                        // Regular mode: show simple timer
                        Spacer()
                        Text("\(max(0, viewStore.timeLeft))s")
                            .font(.headline)
                            .foregroundColor(viewStore.timeLeft <= 5 ? .red : .primary)
                            .padding(.horizontal, UI.Padding.medium)
                            .padding(.vertical, UI.Padding.small)
                            .background(viewStore.timeLeft <= 5 ? Color.red.opacity(0.1) : Color.muted)
                            .cornerRadius(UI.corner)
                    }
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
                                        
                                        // For blitz mode, auto-advance after a short delay
                                        if viewStore.quizMode == .blitz {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                viewStore.send(.next)
                                            }
                                        } else {
                                        showExplanation = true
                                        }
                                        
                                        // Check if answer is correct first
                                        let isCorrect = index == question.correctAnswer
                                        
                                        // Haptic feedback based on correctness
                                        if isCorrect {
                                            let successFeedback = UINotificationFeedbackGenerator()
                                            successFeedback.notificationOccurred(.success)
                                        } else {
                                            let errorFeedback = UINotificationFeedbackGenerator()
                                            errorFeedback.notificationOccurred(.error)
                                        }
                                        
                                        // Answer animation
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            answerAnimations[index] = true
                                        }
                                        
                                        if !isCorrect {
                                            // Shake animation for wrong answer
                                            withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                                answerShake[index] = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                answerShake[index] = false
                                            }
                                        }
                                        
                                        // Reset animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            answerAnimations[index] = false
                                        }
                                    }) {
                                        HStack {
                                            Text("\(Character(UnicodeScalar(65 + index)!))")
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                                .frame(width: 30, height: 30)
                                                .background(
                                                    selectedAnswer == index ? 
                                                    (index == question.correctAnswer ? Color.green : Color.red) : 
                                                    Color.muted
                                                )
                                                .cornerRadius(15)
                                                .overlay(
                                                    // Checkmark for correct answer
                                                    Group {
                                                        if selectedAnswer == index && index == question.correctAnswer {
                                                            Image(systemName: "checkmark")
                                                                .font(.caption)
                                                                .foregroundColor(.white)
                                                                .scaleEffect(answerAnimations[index] == true ? 1.2 : 1.0)
                                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[index])
                                                        }
                                                    }
                                                )
                                            
                                            Text(option)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            selectedAnswer == index ? 
                                            (index == question.correctAnswer ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : 
                                            Color.muted
                                        )
                                        .cornerRadius(UI.corner)
                                        .scaleEffect(answerAnimations[index] == true ? 1.05 : 1.0)
                                        .offset(x: answerShake[index] == true ? 5 : 0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[index])
                                        .animation(.easeInOut(duration: 0.1), value: answerShake[index])
                                    }
                                    .disabled(showExplanation)
                                }
                            }
                        } else if question.mode == .trueFalse {
                            HStack(spacing: UI.Spacing.large) {
                                Button(action: {
                                    selectedBool = true
                                    viewStore.send(.answerBool(true))
                                    
                                    // For blitz mode, auto-advance after a short delay
                                    if viewStore.quizMode == .blitz {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            viewStore.send(.next)
                                        }
                                    } else {
                                    showExplanation = true
                                    }
                                    
                                    // Check if answer is correct first
                                    let isCorrect = question.correctAnswer == true
                                    
                                    // Haptic feedback based on correctness
                                    if isCorrect {
                                        let successFeedback = UINotificationFeedbackGenerator()
                                        successFeedback.notificationOccurred(.success)
                                    } else {
                                        let errorFeedback = UINotificationFeedbackGenerator()
                                        errorFeedback.notificationOccurred(.error)
                                    }
                                    
                                    // Animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        answerAnimations[0] = true
                                    }
                                    
                                    if !isCorrect {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                            answerShake[0] = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            answerShake[0] = false
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        answerAnimations[0] = false
                                    }
                                }) {
                                    Text("SANT")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedBool == true ? 
                                            (question.answer == true ? Color.green : Color.red) : 
                                            Color.primary
                                        )
                                        .cornerRadius(UI.corner)
                                        .scaleEffect(answerAnimations[0] == true ? 1.05 : 1.0)
                                        .offset(x: answerShake[0] == true ? 5 : 0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[0])
                                        .animation(.easeInOut(duration: 0.1), value: answerShake[0])
                                }
                                .disabled(showExplanation)
                                
                                Button(action: {
                                    selectedBool = false
                                    viewStore.send(.answerBool(false))
                                    
                                    // For blitz mode, auto-advance after a short delay
                                    if viewStore.quizMode == .blitz {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            viewStore.send(.next)
                                        }
                                    } else {
                                    showExplanation = true
                                    }
                                    
                                    // Check if answer is correct first
                                    let isCorrect = question.correctAnswer == false
                                    
                                    // Haptic feedback based on correctness
                                    if isCorrect {
                                        let successFeedback = UINotificationFeedbackGenerator()
                                        successFeedback.notificationOccurred(.success)
                                    } else {
                                        let errorFeedback = UINotificationFeedbackGenerator()
                                        errorFeedback.notificationOccurred(.error)
                                    }
                                    
                                    // Animation
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        answerAnimations[1] = true
                                    }
                                    
                                    if !isCorrect {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                            answerShake[1] = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            answerShake[1] = false
                                        }
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        answerAnimations[1] = false
                                    }
                                }) {
                                    Text("FALSKT")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            selectedBool == false ? 
                                            (question.answer == false ? Color.green : Color.red) : 
                                            Color.primary
                                        )
                                        .cornerRadius(UI.corner)
                                        .scaleEffect(answerAnimations[1] == true ? 1.05 : 1.0)
                                        .offset(x: answerShake[1] == true ? 5 : 0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[1])
                                        .animation(.easeInOut(duration: 0.1), value: answerShake[1])
                                }
                                .disabled(showExplanation)
                            }
                        } else if question.mode == .image {
                            VStack(spacing: UI.Spacing.medium) {
                                // Image
                                if let imageName = question.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 200)
                                        .cornerRadius(UI.corner)
                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                                
                                // Multiple choice options for image questions
                                if let options = question.options {
                                    VStack(spacing: UI.Spacing.medium) {
                                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                                            Button(action: {
                                                selectedAnswer = index
                                                viewStore.send(.answerIndex(index))
                                                
                                                // For blitz mode, auto-advance after a short delay
                                                if viewStore.quizMode == .blitz {
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        viewStore.send(.next)
                                                    }
                                                } else {
                                                    showExplanation = true
                                                }
                                                
                                                // Haptic feedback
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                                impactFeedback.impactOccurred()
                                                
                                                // Answer animation
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    answerAnimations[index] = true
                                                }
                                                
                                                // Check if answer is correct
                                                let isCorrect = index == question.correctIndex
                                                if !isCorrect {
                                                    // Shake animation for wrong answer
                                                    withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                                        answerShake[index] = true
                                                    }
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        answerShake[index] = false
                                                    }
                                                }
                                                
                                                // Reset animation
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    answerAnimations[index] = false
                                                }
                                            }) {
                                                HStack {
                                                    Text("\(Character(UnicodeScalar(65 + index)!))")
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                        .frame(width: 30, height: 30)
                                                        .background(
                                                            selectedAnswer == index ? 
                                                            (index == question.correctIndex ? Color.green : Color.red) : 
                                                            Color.muted
                                                        )
                                                        .cornerRadius(15)
                                                        .overlay(
                                                            // Checkmark for correct answer
                                                            Group {
                                                                if selectedAnswer == index && index == question.correctIndex {
                                                                    Image(systemName: "checkmark")
                                                                        .font(.caption)
                                                                        .foregroundColor(.white)
                                                                        .scaleEffect(answerAnimations[index] == true ? 1.2 : 1.0)
                                                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[index])
                                                                }
                                                            }
                                                        )
                                                    
                                                    Text(option)
                                                        .font(.body)
                                                        .foregroundColor(.primary)
                                                        .multilineTextAlignment(.leading)
                                                    
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(
                                                    selectedAnswer == index ? 
                                                    (index == question.correctIndex ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) : 
                                                    Color.muted
                                                )
                                                .cornerRadius(UI.corner)
                                                .scaleEffect(answerAnimations[index] == true ? 1.05 : 1.0)
                                                .offset(x: answerShake[index] == true ? 5 : 0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: answerAnimations[index])
                                                .animation(.easeInOut(duration: 0.1), value: answerShake[index])
                                            }
                                            .disabled(showExplanation)
                                        }
                                    }
                                }
                            }
                        } else if question.mode == .fillBlank {
                            VStack(spacing: UI.Spacing.medium) {
                                // Text input for fill-in-the-blank
                                VStack(alignment: .leading, spacing: UI.Spacing.small) {
                                    Text("Ditt svar:")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Skriv ditt svar här...", text: $textAnswer)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.body)
                                        .padding()
                                        .background(Color.muted)
                                        .cornerRadius(UI.corner)
                                        .disabled(showExplanation)
                                }
                                
                                // Submit button
                                Button(action: {
                                    viewStore.send(.answerText(textAnswer))
                                    
                                    // For blitz mode, auto-advance after a short delay
                                    if viewStore.quizMode == .blitz {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            viewStore.send(.next)
                                        }
                                    } else {
                                        showExplanation = true
                                    }
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                }) {
                                    Text("Skicka svar")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.primary)
                                        .cornerRadius(UI.corner)
                                }
                                .disabled(showExplanation || textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        
                        // Explanation (hidden for blitz mode)
                        if showExplanation && viewStore.quizMode != .blitz {
                            VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                                Text("Facit")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if question.mode == .recap || question.mode == .image {
                                    if let correctIndex = question.correctIndex,
                                       let options = question.options,
                                       correctIndex < options.count {
                                        Text("Rätt svar: \(options[correctIndex])")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                } else if question.mode == .trueFalse {
                                    Text("Rätt svar: \(question.correctAnswer == true ? "SANT" : "FALSKT")")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                } else if question.mode == .fillBlank {
                                    if let correctText = question.correctText {
                                        Text("Rätt svar: \(correctText)")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
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
                
                // Next Button (hidden for blitz mode)
                if showExplanation && viewStore.quizMode != .blitz {
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
            return "Din tur"
        case .player2:
            return "Väns tur"
        case .finished:
            return "Slutfört"
        case .none:
            return ""
        }
    }
}
