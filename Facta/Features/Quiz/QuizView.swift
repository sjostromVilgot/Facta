import SwiftUI
import ComposableArchitecture

struct QuizView: View {
    let store: StoreOf<QuizReducer>
    
    var body: some View {
        WithViewStore(store, observe: \.mode) { viewStore in
            switch viewStore.state {
            case .overview:
                QuizOverviewView(store: store)
            case .playing:
                QuizGameView(store: store)
            case .result:
                QuizResultView(store: store)
            case .history:
                QuizHistoryView(store: store)
            }
        }
    }
}
