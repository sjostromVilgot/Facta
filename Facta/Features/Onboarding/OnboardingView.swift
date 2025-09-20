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
                case 1:
                    SwipeHintView(store: store)
                case 2:
                    FactsQuizIntroView(store: store)
                case 3:
                    ReadyView(store: store)
                case 4:
                    NotificationSettingsView(store: store)
                default:
                    IntroView(store: store)
                }
            }
        }
    }
}
