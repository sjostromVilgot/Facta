import SwiftUI
import ComposableArchitecture

struct QuizHistoryView: View {
    let store: StoreOf<QuizReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Tillbaka") {
                        viewStore.send(.backToOverview)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Historik")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                .background(Color.muted)
                
                if viewStore.history.isEmpty {
                    // Empty State
                    VStack(spacing: UI.Spacing.large) {
                        Spacer()
                        
                        Image(systemName: "clock")
                            .font(.system(size: 50))
                            .foregroundColor(.muted)
                        
                        Text("Ingen historik än")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Spela ditt första quiz för att se resultat här")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // History List
                    List {
                        ForEach(viewStore.history.reversed(), id: \.id) { result in
                            HistoryRowView(result: result)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
}

struct HistoryRowView: View {
    let result: QuizResult
    
    var body: some View {
        HStack(spacing: UI.Spacing.medium) {
            // Mode Icon
            Image(systemName: modeIcon(result.mode))
                .font(.title2)
                .foregroundColor(modeColor(result.mode))
                .frame(width: 30)
            
            // Result Details
            VStack(alignment: .leading, spacing: UI.Spacing.small) {
                HStack {
                    Text(modeTitle(result.mode))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(result.score)/\(result.total)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text(formatDate(result.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int((Double(result.score) / Double(result.total)) * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if result.bestStreak > 0 {
                        Text("🔥\(result.bestStreak)")
                            .font(.caption)
                            .foregroundColor(.accent)
                    }
                }
            }
        }
        .padding(.vertical, UI.Padding.small)
    }
    
    private func modeIcon(_ mode: QuizMode) -> String {
        switch mode {
        case .recap:
            return "questionmark.circle.fill"
        case .trueFalse:
            return "checkmark.circle.fill"
        case .image:
            return "photo.circle.fill"
        case .fillBlank:
            return "pencil.circle.fill"
        case .blitz:
            return "bolt.circle.fill"
        case .daily:
            return "calendar.circle.fill"
        case .weekly:
            return "calendar.badge.plus"
        case .challenge:
            return "person.2.circle.fill"
        }
    }
    
    private func modeColor(_ mode: QuizMode) -> Color {
        switch mode {
        case .recap:
            return .primary
        case .trueFalse:
            return .secondary
        case .image:
            return .blue
        case .fillBlank:
            return .green
        case .blitz:
            return .orange
        case .daily:
            return .purple
        case .weekly:
            return .red
        case .challenge:
            return .pink
        }
    }
    
    private func modeTitle(_ mode: QuizMode) -> String {
        switch mode {
        case .recap:
            return "Recap-quiz"
        case .trueFalse:
            return "Sant/Falskt"
        case .image:
            return "Bild-quiz"
        case .fillBlank:
            return "Fyll-i-quiz"
        case .blitz:
            return "Blixt-quiz"
        case .daily:
            return "Dagens quiz"
        case .weekly:
            return "Veckans quiz"
        case .challenge:
            return "Utmaning"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
