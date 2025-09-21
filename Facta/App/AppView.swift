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
        WithViewStore(store, observe: \.profile.settings) { settingsViewStore in
            TabView {
                HomeView(
                    store: store.scope(
                        state: \.home,
                        action: AppAction.home
                    )
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(NSLocalizedString("Hem", comment: "Home tab"))
                }

                QuizView(
                    store: store.scope(
                        state: \.quiz,
                        action: AppAction.quiz
                    ),
                    onQuickMatch: {
                        // This will be handled by the parent view
                    }
                )
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text(NSLocalizedString("Quiz", comment: "Quiz tab"))
                }

                FavoritesView(
                    store: store.scope(
                        state: \.favorites,
                        action: AppAction.favorites
                    )
                )
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text(NSLocalizedString("Favoriter", comment: "Favorites tab"))
                }

                ChallengesView(
                    store: store.scope(
                        state: \.challenges,
                        action: AppAction.challenges
                    )
                )
                .tabItem {
                    Image(systemName: "flag.fill")
                    Text(NSLocalizedString("Utmaningar", comment: "Challenges tab"))
                }

                FriendsView(
                    store: store.scope(
                        state: \.friends,
                        action: AppAction.friends
                    )
                )
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text(NSLocalizedString("Vänner", comment: "Friends tab"))
                }

                ProfileView(
                    store: store.scope(
                        state: \.profile,
                        action: AppAction.profile
                    )
                )
                .tabItem {
                    Image(systemName: "person.fill")
                    Text(NSLocalizedString("Profil", comment: "Profile tab"))
                }
            }
            .preferredColorScheme(themeColorScheme(settingsViewStore.state.theme))
            .accentColor(themeAccentColor(settingsViewStore.state.theme))
            .environment(\.locale, .init(identifier: settingsViewStore.state.language))
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
        case .mint, .ocean, .sunset:
            return .light // Custom themes use light mode as base
        }
    }
    
    private func themeAccentColor(_ theme: ThemeChoice) -> Color? {
        switch theme {
        case .mint:
            return .mintAccent
        case .ocean:
            return .oceanAccent
        case .sunset:
            return .sunsetAccent
        default:
            return nil // Use system default
        }
    }
}
