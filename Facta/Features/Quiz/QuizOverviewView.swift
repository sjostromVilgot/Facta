import SwiftUI
import ComposableArchitecture

struct QuizOverviewView: View {
    let store: StoreOf<QuizReducer>
    let onQuickMatch: (() -> Void)?
    
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
                    
                    // Quick Challenge Button
                    QuickChallengeCardView {
                        onQuickMatch?()
                    }
                    
                    // Daily and Weekly Challenges
                    VStack(spacing: UI.Spacing.medium) {
                        DailyChallengeCardView {
                            viewStore.send(.start(.daily))
                        }
                        
                        WeeklyChallengeCardView {
                            viewStore.send(.start(.weekly))
                        }
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
                        
                        QuizModeCardView(
                            title: "Blixt-quiz",
                            subtitle: "60 sekunder",
                            description: "Svara på så många frågor som möjligt under tiden!",
                            icon: "bolt.fill",
                            color: .orange
                        ) {
                            viewStore.send(.start(.blitz))
                        }
                        
                        QuizModeCardView(
                            title: "Utmana vän",
                            subtitle: "2 spelare",
                            description: "Tävla mot en vän i samma quiz!",
                            icon: "person.2.fill",
                            color: .purple
                        ) {
                            viewStore.send(.start(.challenge))
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

struct QuickChallengeCardView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("Snabb utmaning", comment: "Quick challenge"))
                        .font(Typography.headline)
                        .foregroundColor(.adaptiveForeground)
                    
                    Text(NSLocalizedString("Tävla mot en slumpmässig motståndare", comment: "Compete against a random opponent"))
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.orange.opacity(0.1), .red.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(UI.corner)
            .overlay(
                RoundedRectangle(cornerRadius: UI.corner)
                    .stroke(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Daily Challenge Card
struct DailyChallengeCardView: View {
    let action: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "calendar")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(NSLocalizedString("Dagens utmaning", comment: "Daily challenge"))
                            .font(Typography.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        if isCompleted {
                            Text("✅")
                                .font(.caption)
                        }
                    }
                    
                    Text(NSLocalizedString("3 frågor • Nya varje dag", comment: "3 questions • New every day"))
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                        .multilineTextAlignment(.leading)
                    
                    Text(NSLocalizedString("+50 XP bonus", comment: "+50 XP bonus"))
                        .font(Typography.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.green.opacity(0.1), .mint.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(UI.corner)
            .overlay(
                RoundedRectangle(cornerRadius: UI.corner)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .mint.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Check if daily challenge is completed today
            checkDailyCompletion()
        }
    }
    
    private func checkDailyCompletion() {
        // This would check UserDefaults or persistence for today's completion
        // For now, we'll simulate it
        isCompleted = false
    }
}

// MARK: - Weekly Challenge Card
struct WeeklyChallengeCardView: View {
    let action: () -> Void
    @State private var isCompleted = false
    @State private var daysLeft = 0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: isCompleted ? "star.fill" : "star.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(NSLocalizedString("Veckans utmaning", comment: "Weekly challenge"))
                            .font(Typography.headline)
                            .foregroundColor(.adaptiveForeground)
                        
                        if isCompleted {
                            Text("🏆")
                                .font(.caption)
                        }
                    }
                    
                    Text(NSLocalizedString("10 frågor • Veckovis", comment: "10 questions • Weekly"))
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(NSLocalizedString("+200 XP bonus", comment: "+200 XP bonus"))
                            .font(Typography.caption)
                            .foregroundColor(.purple)
                            .fontWeight(.medium)
                        
                        if daysLeft > 0 {
                            Text("• \(daysLeft) dagar kvar")
                                .font(Typography.caption)
                                .foregroundColor(.mutedForeground)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.purple.opacity(0.1), .blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(UI.corner)
            .overlay(
                RoundedRectangle(cornerRadius: UI.corner)
                    .stroke(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Check if weekly challenge is completed this week
            checkWeeklyCompletion()
        }
    }
    
    private func checkWeeklyCompletion() {
        // This would check UserDefaults or persistence for this week's completion
        // For now, we'll simulate it
        isCompleted = false
        daysLeft = 3 // Simulate 3 days left in week
    }
}
