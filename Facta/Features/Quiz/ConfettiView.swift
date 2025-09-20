import SwiftUI

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
