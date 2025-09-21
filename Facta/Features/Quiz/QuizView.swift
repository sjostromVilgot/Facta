import SwiftUI
import ComposableArchitecture

struct QuizView: View {
    let store: StoreOf<QuizReducer>
    let onQuickMatch: (() -> Void)?
    
    init(store: StoreOf<QuizReducer>, onQuickMatch: (() -> Void)? = nil) {
        self.store = store
        self.onQuickMatch = onQuickMatch
    }
    
    var body: some View {
        WithViewStore(store, observe: \.mode) { viewStore in
            Group {
                switch viewStore.state {
                case .overview:
                    QuizOverviewView(store: store, onQuickMatch: onQuickMatch)
                        .id("overview")
                        .transition(.opacity)
                case .playing:
                    QuizGameView(store: store)
                        .id("playing")
                        .transition(.opacity)
                case .result:
                    QuizResultView(store: store)
                        .id("result")
                        .transition(.opacity)
                case .history:
                    QuizHistoryView(store: store)
                        .id("history")
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewStore.state)
        }
    }
}
