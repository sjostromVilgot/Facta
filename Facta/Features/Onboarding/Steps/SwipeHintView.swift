import SwiftUI
import ComposableArchitecture

struct SwipeHintView: View {
    let store: StoreOf<OnboardingReducer>
    @State private var cardOffset: CGFloat = 0
    @State private var isAnimating = false
    @State private var showArrow = false
    
    var body: some View {
        VStack(spacing: UI.Spacing.large) {
            Spacer()
            
            Text("Svep för mer")
                .font(Typography.largeTitle)
                .foregroundColor(.adaptiveForeground)
                .multilineTextAlignment(.center)
            
            // Animated card that slides right
            ZStack {
                // Background card
                RoundedRectangle(cornerRadius: UI.corner)
                    .fill(Color.muted)
                    .frame(width: 300, height: 200)
                    .opacity(0.3)
                
                // Animated card
                FactCardView(
                    fact: Fact(
                        id: "swipe-demo",
                        title: "Flamingos färg",
                        content: "De blir rosa av karotenoider i räkor och alger.",
                        category: "Djur",
                        tags: [FactTag(emoji: "🦩", label: "Djur")],
                        readTime: 20,
                        isPremium: false
                    ),
                    isSaved: false,
                    onSave: {},
                    onShare: {},
                    dragOffset: cardOffset
                )
                .frame(width: 300, height: 200)
                .offset(x: cardOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                cardOffset = value.translation.width
                            }
                            .onEnded { value in
                                withAnimation(.spring()) {
                                    cardOffset = 0
                                }
                            }
                    )
                .onAppear {
                    startAnimation()
                }
            }
            .frame(height: 200)
            
            // Instruction text with pulsing arrow
            HStack {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .opacity(showArrow ? 1.0 : 0.3)
                Text("Svep åt höger")
                    .font(Typography.subheadline)
                    .foregroundColor(.mutedForeground)
            }
            .onAppear {
                // animera pil blinkande
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    showArrow.toggle()
                }
            }
            
            Spacer()
            
            Button("Nästa") {
                Task {
                    withAnimation(.spring()) {
                        store.send(.nextStep)
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, UI.Padding.large)
            
            Spacer()
        }
        .padding()
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                cardOffset = 100
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    cardOffset = 0
                }
            }
        }
    }
}
