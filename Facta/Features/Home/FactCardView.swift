import SwiftUI
import ComposableArchitecture
import UIKit

struct FactCardView: View {
    let fact: Fact
    let isSaved: Bool
    let onSave: () -> Void
    let onShare: () -> Void
    let onNext: (() -> Void)?
    let dragOffset: CGFloat
    @State private var showingShare = false
    @State private var heartAnimation = false
    @State private var heartScale: CGFloat = 1.0
    
    init(fact: Fact, isSaved: Bool = false, onSave: @escaping () -> Void, onShare: @escaping () -> Void, onNext: (() -> Void)? = nil, dragOffset: CGFloat = 0) {
        self.fact = fact
        self.isSaved = isSaved
        self.onSave = onSave
        self.onShare = onShare
        self.onNext = onNext
        self.dragOffset = dragOffset
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tags
            if !fact.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(fact.tags, id: \.label) { tag in
                        Text("\(tag.emoji) \(tag.label)")
                            .font(Typography.caption)
                            .foregroundColor(.mutedForeground)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.muted)
                            .cornerRadius(50)
                    }
                }
            }
            
            // Title
            Text(fact.title)
                .font(Typography.headline)
                .foregroundColor(.adaptiveForeground)
                .lineLimit(2)
                .padding(.bottom, 8)
            
            // Content preview
            Text(fact.content)
                .font(Typography.subheadline)
                .foregroundColor(.mutedForeground)
                .lineLimit(3)
                .padding(.bottom, 8)
            
            // Actions
            HStack {
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    // Heart animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        heartScale = 1.3
                        heartAnimation = true
                    }
                    
                    // Reset animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            heartScale = 1.0
                        }
                    }
                    
                    // Reset animation flag
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        heartAnimation = false
                    }
                    
                    onSave()
                }) {
                    Label(isSaved ? "Sparad" : "Spara", systemImage: isSaved ? "heart.fill" : "heart")
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isSaved ? Color.red.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .scaleEffect(heartScale)
                        .overlay(
                            // Pulse effect
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .scaleEffect(heartAnimation ? 1.5 : 0.8)
                                .opacity(heartAnimation ? 0 : 1)
                                .animation(.easeOut(duration: 0.6), value: heartAnimation)
                        )
                }
                .buttonStyle(CardButtonStyle())
                .foregroundColor(isSaved ? .red : .primary)
                
                Button(action: {
                    showingShare = true
                }) {
                    Label("Dela", systemImage: "square.and.arrow.up")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonStyle(CardButtonStyle())
                .foregroundColor(.primary)
                
                Spacer()
                
                if let onNext = onNext {
                    Button(action: onNext) {
                        HStack(spacing: 4) {
                            Text("Nästa")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(Typography.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.top, UI.Padding.small)
            .overlay(
                Rectangle()
                    .fill(Color.adaptiveSeparator)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .padding(UI.Padding.large)
        .background(cardBackground)
        .cornerRadius(UI.corner)
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: UI.corner)
                .stroke(
                    dragFeedbackColor, 
                    lineWidth: dragFeedbackColor == .clear ? 0 : 2
                )
        )
        .sheet(isPresented: $showingShare) {
            ActivityView(activityItems: [
                "\(fact.title)\n\n\(fact.content)\n\nLadda ner Facta för mer fantastiska fakta! 📱"
            ])
        }
    }
    
    private var cardBackground: LinearGradient {
        if fact.isPremium {
            return LinearGradient(
                colors: [Color.primary.opacity(0.1), Color.accent.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // Hjälpberäknad färg för svepram
    private var dragFeedbackColor: Color {
        if onNext == nil { return .clear }            // bara i Discovery-läge
        if dragOffset > 50 { return .green }
        if dragOffset < -50 { return .red }
        return .clear
    }
}

// MARK: - ActivityView
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

// MARK: - CardButtonStyle
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
