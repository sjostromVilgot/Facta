import SwiftUI
import ComposableArchitecture

struct IntroView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        VStack(spacing: UI.Spacing.large) {
            Spacer()
            
            VStack(spacing: UI.Spacing.medium) {
                Text("Onödig fakta.")
                    .font(Typography.largeTitle)
                    .foregroundColor(.primary)
                
                Text("Oändligt kul.")
                    .font(Typography.largeTitle)
                    .foregroundColor(.primary)
            }
            
            // Dummy fact cards in ZStack
            ZStack {
                FactCardView(
                    fact: Fact(
                        id: "dummy1",
                        title: "Bläckfiskar har tre hjärtan",
                        content: "Två pumpar blod till gälarna och ett till resten av kroppen.",
                        category: "Djur",
                        tags: [FactTag(emoji: "🐙", label: "Djur")],
                        readTime: 20,
                        isPremium: false
                    )
                )
                .offset(x: -20, y: 10)
                .rotationEffect(.degrees(-5))
                .opacity(0.7)
                
                FactCardView(
                    fact: Fact(
                        id: "dummy2",
                        title: "Honung förstörs aldrig",
                        content: "Arkeologer har hittat krukor med honung från forntiden som fortfarande är ätbar.",
                        category: "Matvetenskap",
                        tags: [FactTag(emoji: "🍯", label: "Mat")],
                        readTime: 30,
                        isPremium: true
                    )
                )
                .offset(x: 20, y: -10)
                .rotationEffect(.degrees(5))
                .opacity(0.8)
                
                FactCardView(
                    fact: Fact(
                        id: "dummy3",
                        title: "Bananer är bär",
                        content: "Botaniskt är bananer bär medan jordgubbar inte är det.",
                        category: "Botanik",
                        tags: [FactTag(emoji: "🍌", label: "Växter")],
                        readTime: 20,
                        isPremium: false
                    )
                )
                .opacity(0.9)
            }
            .frame(height: 200)
            
            Spacer()
            
            Button("Nästa") {
                store.send(.nextStep)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, UI.Padding.large)
            
            Spacer()
        }
        .padding()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, UI.Padding.large)
            .padding(.vertical, UI.Padding.medium)
            .background(Color.primary)
            .cornerRadius(UI.corner)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
