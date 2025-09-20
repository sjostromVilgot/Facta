import SwiftUI
import ComposableArchitecture

struct FactsQuizIntroView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        VStack(spacing: UI.Spacing.large) {
            Spacer()
            
            Text("Dagens fakta & quiz")
                .font(Typography.largeTitle)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: UI.Spacing.large) {
                FeatureIconView(
                    icon: "🔥",
                    title: "Dagens fakta",
                    description: "Få en ny fascinerande fakta varje dag"
                )
                
                FeatureIconView(
                    icon: "⚡️",
                    title: "Snabb quiz",
                    description: "Testa dina kunskaper med snabba frågor"
                )
                
                FeatureIconView(
                    icon: "⭐️",
                    title: "Samla poäng",
                    description: "Tjäna poäng och lås upp nya nivåer"
                )
            }
            
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

struct FeatureIconView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: UI.Spacing.medium) {
            Text(icon)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: UI.Spacing.small) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.muted)
        .cornerRadius(UI.corner)
    }
}
