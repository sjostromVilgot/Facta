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
                    ConfettiView()
                }
            }
        }
    }
    
    private func mainContent(viewStore: ViewStore<QuizState, QuizAction>) -> some View {
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
            scoreDetailsView(viewStore: viewStore)
            
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
            
            Button("Tillbaka till quiz-meny") {
                viewStore.send(.backToOverview)
            }
            .buttonStyle(SecondaryButtonStyle())
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
    
    private func shouldShowConfetti(score: Int, total: Int) -> Bool {
        let percentage = Double(score) / Double(total)
        return percentage >= 0.8 // Show confetti for 80% or higher
    }
}

// MARK: - ConfettiView
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    let emojis: [String] = ["🎉", "✨", "⭐", "🌟", "💫", "🎊", "🎈"]
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Text(piece.emoji)
                    .font(.system(size: piece.size))
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Create confetti pieces
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                id: UUID(),
                emoji: emojis.randomElement() ?? "🎉",
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: -50,
                size: Double.random(in: 20...40),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
        }
        
        // Animate confetti falling
        withAnimation(.easeOut(duration: 3.0)) {
            for i in confettiPieces.indices {
                confettiPieces[i].y = UIScreen.main.bounds.height + 100
                confettiPieces[i].rotation += 360
                confettiPieces[i].opacity = 0.0
            }
        }
        
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            confettiPieces = []
            isAnimating = false
        }
    }
}

struct ConfettiPiece {
    let id: UUID
    let emoji: String
    var x: Double
    var y: Double
    let size: Double
    var rotation: Double
    var opacity: Double
}
