import SwiftUI
import ComposableArchitecture

struct QuizResultView: View {
    let store: StoreOf<QuizReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                mainContent(viewStore: viewStore)
                
                // Confetti effect for good scores
                if shouldShowConfetti(score: viewStore.score, total: viewStore.questions.count) {
                    ConfettiView(
                        colors: [.green, .blue, .purple, .yellow, .orange, .pink],
                        duration: 2.5,
                        intensity: 60
                    )
                }
            }
        }
    }
    
    private func mainContent(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.large) {
            Spacer()
            
            if viewStore.quizMode == .challenge {
                // Challenge Results
                challengeResultsView(viewStore: viewStore)
            } else {
                // Regular Results
                // Result Icon
                Image(systemName: resultIcon(score: viewStore.score, total: viewStore.questions.count))
                    .font(.system(size: 80))
                    .foregroundColor(resultColor(score: viewStore.score, total: viewStore.questions.count))
            
                // Result Title
                Text(resultTitle(score: viewStore.score, total: viewStore.questions.count))
                    .font(Typography.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // Score Details
                scoreDetailsView(viewStore: viewStore)
            }
            
            // Action Buttons
            actionButtonsView(viewStore: viewStore)
            
            Spacer()
        }
        .padding()
    }
    
    private func scoreDetailsView(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.medium) {
            HStack {
                Text("Poäng:")
                    .font(Typography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewStore.score)/\(viewStore.questions.count)")
                    .font(Typography.headline)
                    .foregroundColor(.primary)
            }
            
            HStack {
                Text("Procent:")
                    .font(Typography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int((Double(viewStore.score) / Double(viewStore.questions.count)) * 100))%")
                    .font(Typography.headline)
                    .foregroundColor(.primary)
            }
            
            if viewStore.streak > 0 {
                HStack {
                    Text("🔥 Streak:")
                        .font(Typography.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(viewStore.streak)")
                        .font(Typography.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color.muted)
        .cornerRadius(UI.corner)
    }
    
    private func actionButtonsView(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.medium) {
            Button("Prova ett nytt quiz") {
                viewStore.send(.backToOverview)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            // Share Button
            ShareButton(
                shareText: shareText(score: viewStore.score, total: viewStore.questions.count, mode: viewStore.quizMode)
            )
            
            Button("Tillbaka till quiz-meny") {
                viewStore.send(.backToOverview)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    private func challengeResultsView(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
        VStack(spacing: UI.Spacing.large) {
            // Challenge Icon
            Image(systemName: "person.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.purple)
            
            // Challenge Title
            Text("Utmaning slutförd!")
                .font(Typography.largeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Score Comparison
            VStack(spacing: UI.Spacing.medium) {
                HStack {
                    VStack {
                        Text("Du")
                            .font(Typography.headline)
                            .foregroundColor(.primary)
                        Text("\(viewStore.playerOneScore)/\(viewStore.questions.count)")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(UI.corner)
                    
                    Text("VS")
                        .font(Typography.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack {
                        Text("Vän")
                            .font(Typography.headline)
                            .foregroundColor(.primary)
                        Text("\(viewStore.playerTwoScore)/\(viewStore.questions.count)")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(UI.corner)
                }
                
                // Winner Announcement
                VStack(spacing: UI.Spacing.small) {
                    if viewStore.playerOneScore > viewStore.playerTwoScore {
                        Text("Du vann! 🎉")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if viewStore.playerTwoScore > viewStore.playerOneScore {
                        Text("Du förlorade")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    } else {
                        Text("Oavgjort!")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Text("Bra jobbat båda!")
                        .font(Typography.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.muted)
                .cornerRadius(UI.corner)
            }
        }
    }
    
    private func shareText(score: Int, total: Int, mode: QuizMode?) -> String {
        let percentage = Int((Double(score) / Double(total)) * 100)
        let modeText = mode?.displayName ?? "quiz"
        
        return "Jag fick \(percentage)% rätt på en \(modeText) i Facta! 🧠✨\n\nLadda ner Facta för att testa dina kunskaper också!"
    }
    
    private func resultIcon(score: Int, total: Int) -> String {
        let percentage = Double(score) / Double(total)
        if percentage >= 1.0 {
            return "trophy.fill"
        } else if percentage >= 0.7 {
            return "star.fill"
        } else {
            return "brain.head.profile"
        }
    }
    
    private func resultColor(score: Int, total: Int) -> Color {
        let percentage = Double(score) / Double(total)
        if percentage >= 1.0 {
            return .accent
        } else if percentage >= 0.7 {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private func resultTitle(score: Int, total: Int) -> String {
        let percentage = Double(score) / Double(total)
        if percentage >= 1.0 {
            return "Perfekt poäng!"
        } else if percentage >= 0.7 {
            return "Bra jobbat!"
        } else {
            return "Bra försök!"
        }
    }
    
    private func shouldShowConfetti(score: Int, total: Int) -> Bool {
        let percentage = Double(score) / Double(total)
        return percentage >= 0.8 // Show confetti for 80% or higher
    }
}

// MARK: - ConfettiView
