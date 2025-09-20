import SwiftUI
import ComposableArchitecture

@main
struct FactaApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: AppState()) {
                    AppReducer()
                }
            )
            .accentColor(.primary)
        }
    }
}
