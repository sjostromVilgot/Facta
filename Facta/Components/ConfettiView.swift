import SwiftUI
import UIKit

struct ConfettiView: View {
    @State private var isAnimating = false
    @State private var confettiPieces: [ConfettiPiece] = []
    let colors: [Color]
    let duration: Double
    let intensity: Int
    
    init(
        colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange],
        duration: Double = 2.0,
        intensity: Int = 50
    ) {
        self.colors = colors
        self.duration = duration
        self.intensity = intensity
    }
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        // Generate confetti pieces
        confettiPieces = (0..<intensity).map { _ in
            ConfettiPiece(
                id: UUID(),
                x: Double.random(in: 0...1),
                y: -0.1,
                rotation: Double.random(in: 0...360),
                color: colors.randomElement() ?? .blue,
                shape: ConfettiShape.allCases.randomElement() ?? .circle
            )
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Start animation
        withAnimation(.easeOut(duration: duration)) {
            isAnimating = true
        }
        
        // Remove confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            confettiPieces.removeAll()
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var rotation: Double
    let color: Color
    let shape: ConfettiShape
}

enum ConfettiShape: CaseIterable {
    case circle
    case square
    case triangle
    case star
    case diamond
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var isAnimating = false
    
    var body: some View {
        Group {
            switch piece.shape {
            case .circle:
                Circle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            case .square:
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            case .triangle:
                Triangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            case .star:
                Star()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            case .diamond:
                Diamond()
                    .fill(piece.color)
                    .frame(width: 8, height: 8)
            }
        }
        .rotationEffect(.degrees(piece.rotation))
        .position(
            x: piece.x * UIScreen.main.bounds.width,
            y: piece.y * UIScreen.main.bounds.height
        )
        .onAppear {
            withAnimation(
                .easeOut(duration: 2.0)
                .delay(Double.random(in: 0...0.5))
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - Celebration Overlay
struct CelebrationOverlay: View {
    let isVisible: Bool
    let type: CelebrationType
    let onComplete: () -> Void
    
    @State private var showConfetti = false
    @State private var showMessage = false
    
    var body: some View {
        ZStack {
            if isVisible {
                // Confetti
                ConfettiView(
                    colors: type.colors,
                    duration: type.duration,
                    intensity: type.intensity
                )
                .opacity(showConfetti ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.3)) {
                        showConfetti = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showMessage = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + type.duration) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showConfetti = false
                            showMessage = false
                        }
                        onComplete()
                    }
                }
                
                // Celebration message
                if showMessage {
                    VStack(spacing: 16) {
                        Image(systemName: type.icon)
                            .font(.system(size: 60))
                            .foregroundColor(type.primaryColor)
                            .scaleEffect(showMessage ? 1.0 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showMessage)
                        
                        Text(type.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(type.subtitle)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [type.primaryColor.opacity(0.9), type.secondaryColor.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    )
                    .scaleEffect(showMessage ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showMessage)
                }
            }
        }
    }
}

enum CelebrationType {
    case levelUp
    case badgeUnlocked
    case quizPerfect
    case quizHighScore
    case streakMilestone
    
    var colors: [Color] {
        switch self {
        case .levelUp:
            return [.blue, .purple, .pink, .yellow]
        case .badgeUnlocked:
            return [.yellow, .orange, .red, .pink]
        case .quizPerfect:
            return [.green, .mint, .blue, .purple]
        case .quizHighScore:
            return [.orange, .yellow, .red, .pink]
        case .streakMilestone:
            return [.red, .orange, .yellow, .pink]
        }
    }
    
    var duration: Double {
        switch self {
        case .levelUp:
            return 3.0
        case .badgeUnlocked:
            return 2.5
        case .quizPerfect:
            return 2.0
        case .quizHighScore:
            return 1.5
        case .streakMilestone:
            return 2.0
        }
    }
    
    var intensity: Int {
        switch self {
        case .levelUp:
            return 80
        case .badgeUnlocked:
            return 60
        case .quizPerfect:
            return 70
        case .quizHighScore:
            return 50
        case .streakMilestone:
            return 60
        }
    }
    
    var icon: String {
        switch self {
        case .levelUp:
            return "star.fill"
        case .badgeUnlocked:
            return "trophy.fill"
        case .quizPerfect:
            return "checkmark.circle.fill"
        case .quizHighScore:
            return "chart.line.uptrend.xyaxis"
        case .streakMilestone:
            return "flame.fill"
        }
    }
    
    var title: String {
        switch self {
        case .levelUp:
            return NSLocalizedString("Nivå upp!", comment: "Level up!")
        case .badgeUnlocked:
            return NSLocalizedString("Badge låst upp!", comment: "Badge unlocked!")
        case .quizPerfect:
            return NSLocalizedString("Perfekt resultat!", comment: "Perfect score!")
        case .quizHighScore:
            return NSLocalizedString("Nytt rekord!", comment: "New record!")
        case .streakMilestone:
            return NSLocalizedString("Streak-milestone!", comment: "Streak milestone!")
        }
    }
    
    var subtitle: String {
        switch self {
        case .levelUp:
            return NSLocalizedString("Du har gått upp en nivå!", comment: "You've leveled up!")
        case .badgeUnlocked:
            return NSLocalizedString("Grattis till din nya badge!", comment: "Congratulations on your new badge!")
        case .quizPerfect:
            return NSLocalizedString("100% rätt - fantastiskt!", comment: "100% correct - fantastic!")
        case .quizHighScore:
            return NSLocalizedString("Du slog ditt tidigare rekord!", comment: "You beat your previous record!")
        case .streakMilestone:
            return NSLocalizedString("Imponerande streak!", comment: "Impressive streak!")
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .levelUp:
            return .blue
        case .badgeUnlocked:
            return .yellow
        case .quizPerfect:
            return .green
        case .quizHighScore:
            return .orange
        case .streakMilestone:
            return .red
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .levelUp:
            return .purple
        case .badgeUnlocked:
            return .orange
        case .quizPerfect:
            return .blue
        case .quizHighScore:
            return .red
        case .streakMilestone:
            return .orange
        }
    }
}
