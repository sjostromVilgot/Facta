import SwiftUI
import ComposableArchitecture

struct QuizResultView: View {
    let store: StoreOf<QuizReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: UI.Spacing.large) {
                Spacer()
                
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
                VStack(spacing: UI.Spacing.medium) {
                    HStack {
                        Text("Poäng:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(viewStore.score)/\(viewStore.questions.count)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Procent:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int((Double(viewStore.score) / Double(viewStore.questions.count)) * 100))%")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if viewStore.streak > 0 {
                        HStack {
                            Text("🔥 Streak:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(viewStore.streak)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color.muted)
                .cornerRadius(UI.corner)
                
                // Action Buttons
                VStack(spacing: UI.Spacing.medium) {
                    Button("Prova ett nytt quiz") {
                        viewStore.send(.backToOverview)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Tillbaka till quiz-meny") {
                        viewStore.send(.backToOverview)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Spacer()
            }
            .padding()
        }
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
}
