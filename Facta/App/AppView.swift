import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if !viewStore.onboardingComplete {
                OnboardingView(
                    store: store.scope(
                        state: \.onboarding,
                        action: AppAction.onboarding
                    )
                )
            } else {
                MainTabView(store: store)
            }
        }
    }
}

struct MainTabView: View {
    let store: StoreOf<AppReducer>

    var body: some View {
        WithViewStore(store, observe: \.profile.settings.theme) { viewStore in
            TabView {
                HomeView(
                    store: store.scope(
                        state: \.home,
                        action: AppAction.home
                    )
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Hem")
                }

                QuizView(
                    store: store.scope(
                        state: \.quiz,
                        action: AppAction.quiz
                    )
                )
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quiz")
                }

                FavoritesView(
                    store: store.scope(
                        state: \.favorites,
                        action: AppAction.favorites
                    )
                )
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoriter")
                }

                ProfileView(
                    store: store.scope(
                        state: \.profile,
                        action: AppAction.profile
                    )
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
            }
            .preferredColorScheme(themeColorScheme(viewStore.state))
        }
    }
    
    private func themeColorScheme(_ theme: ThemeChoice) -> ColorScheme? {
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
