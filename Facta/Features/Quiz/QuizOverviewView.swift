import SwiftUI
import ComposableArchitecture

struct QuizOverviewView: View {
    let store: StoreOf<QuizReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: UI.Spacing.large) {
                    // Header
                    Text("Quiz")
                        .font(Typography.largeTitle)
                        .foregroundColor(.primary)
                        .padding(.top)
                    
                    // Stats Cards
                    HStack(spacing: UI.Spacing.medium) {
                        StatCardView(
                            title: "Senaste",
                            value: "\(latestScorePercentage(from: viewStore.history))%",
                            icon: "chart.bar.fill",
                            valueColor: .accent
                        )
                        
                        StatCardView(
                            title: "Bästa streak",
                            value: "\(bestStreak(from: viewStore.history))",
                            icon: "flame.fill",
                            valueColor: .orange
                        )
                        
                        StatCardView(
                            title: "Badges",
                            value: "\(badgeCount(from: viewStore.history))",
                            icon: "star.fill",
                            valueColor: .green
                        )
                    }
                    
                    // Quiz Mode Cards
                    VStack(spacing: UI.Spacing.medium) {
                        QuizModeCardView(
                            title: "Recap-quiz",
                            subtitle: "5 frågor • 15s",
                            description: "Testa dina kunskaper med flervalsfrågor",
                            icon: "questionmark.circle.fill",
                            color: .primary
                        ) {
                            viewStore.send(.start(.recap))
                        }
                        
                        QuizModeCardView(
                            title: "Sant/Falskt",
                            subtitle: "10 frågor • streak",
                            description: "Snabbare tempo med sant/falskt-frågor",
                            icon: "checkmark.circle.fill",
                            color: .secondary
                        ) {
                            viewStore.send(.start(.trueFalse))
                        }
                    }
                    
                    // History Button
                    Button(action: {
                        viewStore.send(.showHistory)
                    }) {
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Historik")
                        }
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.muted)
                        .cornerRadius(UI.corner)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private func latestScorePercentage(from history: [QuizResult]) -> Int {
        guard let latest = history.last else { return 0 }
        return Int((Double(latest.score) / Double(latest.total)) * 100)
    }
    
    private func bestStreak(from history: [QuizResult]) -> Int {
        return history.map(\.bestStreak).max() ?? 0
    }
    
    private func badgeCount(from history: [QuizResult]) -> Int {
        // TODO: Implement actual badge logic
        return history.count / 5 // Placeholder
    }
}


struct QuizModeCardView: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: UI.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: UI.Spacing.small) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.muted)
            .cornerRadius(UI.corner)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
