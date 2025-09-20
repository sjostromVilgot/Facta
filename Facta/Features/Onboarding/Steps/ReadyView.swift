import SwiftUI
import ComposableArchitecture

struct ReadyView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        VStack(spacing: UI.Spacing.large) {
            Spacer()
            
            VStack(spacing: UI.Spacing.medium) {
                Text("Redo att börja?")
                    .font(Typography.largeTitle)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Du är redo att utforska världen av fascinerande fakta!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button("Kom igång") {
                Task {
                    withAnimation(.spring()) {
                        store.send(.getStartedTapped)
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, UI.Padding.large)
            
            Spacer()
        }
        .padding()
    }
}
