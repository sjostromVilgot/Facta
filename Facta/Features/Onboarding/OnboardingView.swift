import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<OnboardingReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                Color.adaptiveBackground
                    .ignoresSafeArea()
                
                switch viewStore.currentStep {
                case 0:
                    IntroView(store: store)
                        .id("step0")
                        .transition(.move(edge: .trailing))
                case 1:
                    SwipeHintView(store: store)
                        .id("step1")
                        .transition(.move(edge: .trailing))
                case 2:
                    FactsQuizIntroView(store: store)
                        .id("step2")
                        .transition(.move(edge: .trailing))
                case 3:
                    ReadyView(store: store)
                        .id("step3")
                        .transition(.move(edge: .trailing))
                case 4:
                    NotificationSettingsView(store: store)
                        .id("step4")
                        .transition(.move(edge: .trailing))
                default:
                    IntroView(store: store)
                        .id("step0")
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewStore.currentStep)
        }
    }
}
