import SwiftUI
import ComposableArchitecture
import UIKit
import Charts

struct ProfileView: View {
    let store: Store<ProfileState, ProfileAction>
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var celebrationType: CelebrationType?
    @State private var previousLevel = 1
    @State private var previousBadgeCount = 0
    @State private var xpAnimation = false
    @State private var badgeAnimation = false
    @State private var showingLeaderboard = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                ScrollView {
                    mainContent(viewStore: viewStore)
                }
                .onAppear {
                    viewStore.send(.load)
                    checkForCelebrations(viewStore: viewStore)
                }
                .onChange(of: viewStore.stats.level) { newLevel in
                    if newLevel > previousLevel {
                        celebrationType = .levelUp
                        previousLevel = newLevel
                    }
                }
                .onChange(of: viewStore.badges.count) { newCount in
                    if newCount > previousBadgeCount {
                        celebrationType = .badgeUnlocked
                        previousBadgeCount = newCount
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView(store: store)
                }
                .sheet(isPresented: $showingAbout) {
                    AboutView()
                }
                .sheet(isPresented: $showingLeaderboard) {
                    Text("Topplista kommer snart!")
                        .padding()
                }
                
                // Celebration Overlay
                if let celebrationType = celebrationType {
                    CelebrationOverlay(
                        isVisible: celebrationType != nil,
                        type: celebrationType,
                        onComplete: {
                            self.celebrationType = nil
                        }
                    )
                }
                
                // Confetti overlay for level up
                if viewStore.leveledUp {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                viewStore.send(.acknowledgeLevelUp)
                            }
                        }
                }
                
                // Confetti overlay for challenge completion
                if viewStore.challengeCompleted {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                viewStore.send(.acknowledgeChallengeComplete)
                            }
                        }
                }
            }
        }
    }
    
    private func mainContent(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(spacing: UI.Spacing.large) {
            // Header
            VStack(spacing: UI.Spacing.medium) {
                // Avatar
                AvatarView(avatarData: viewStore.avatarData, displayName: viewStore.settings.displayName)
                
                // Name and Streak
                VStack(spacing: UI.Spacing.small) {
                    Text(viewStore.settings.displayName)
                        .font(Typography.title2)
                        .foregroundColor(.adaptiveForeground)
                    
                    StreakDisplayView(streakDays: viewStore.stats.streakDays)
                }
            }
            .padding()
            
            // Level and XP Progress
            LevelProgressView(stats: viewStore.stats)
            .padding()
            .background(Color.muted)
            .cornerRadius(UI.corner)
            .padding(.horizontal)
            
            // Statistics Charts Section
            statisticsChartsSection(viewStore: viewStore)
            
            // Stats Cards
            statsCardsSection(viewStore: viewStore)
            
            // Badges Section
            badgesSection(viewStore: viewStore)
            
            // Action Buttons
            actionButtonsSection(viewStore: viewStore)
        }
        .padding(.vertical)
    }
    
    private func statisticsChartsSection(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            Text("Din statistik")
                .font(Typography.headline)
                .foregroundColor(.adaptiveForeground)
                .padding(.horizontal)
            
            // Quiz Performance Chart
            quizPerformanceChart(viewStore: viewStore)
            
            // Weekly Activity Chart
            weeklyActivityChart(viewStore: viewStore)
        }
    }
    
    private func quizPerformanceChart(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            Text("Quiz-prestation (senaste 7)")
                .font(Typography.subheadline)
                .foregroundColor(.mutedForeground)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                let chartData = viewStore.quizHistory.prefix(7).enumerated().map { index, result in
                    QuizChartData(
                        index: index + 1,
                        score: Double(result.score) / Double(result.total) * 100,
                        date: result.date
                    )
                }
                
                Chart(chartData, id: \.index) { data in
                    LineMark(
                        x: .value("Quiz", data.index),
                        y: .value("Poäng %", data.score)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Quiz", data.index),
                        y: .value("Poäng %", data.score)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 150)
                .padding(.horizontal)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let score = value.as(Double.self) {
                                Text("\(Int(score))%")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let index = value.as(Int.self) {
                                Text("\(index)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(viewStore.quizHistory.prefix(7).enumerated()), id: \.offset) { index, result in
                        let percentage = Double(result.score) / Double(result.total) * 100
                        VStack {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: CGFloat(percentage * 1.5))
                                .cornerRadius(4)
                            
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundColor(.mutedForeground)
                        }
                    }
                }
                .frame(height: 150)
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.muted.opacity(0.3))
        .cornerRadius(UI.corner)
        .padding(.horizontal)
    }
    
    private func weeklyActivityChart(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.small) {
            Text("Veckoaktivitet")
                .font(Typography.subheadline)
                .foregroundColor(.mutedForeground)
                .padding(.horizontal)
            
            if #available(iOS 16.0, *) {
                let weeklyData = generateWeeklyActivityData()
                Chart(weeklyData) { data in
                    BarMark(
                        x: .value("Dag", data.day),
                        y: .value("Fakta", data.factsRead)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 120)
                .padding(.horizontal)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let facts = value.as(Int.self) {
                                Text("\(facts)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.caption)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(generateWeeklyActivityData(), id: \.day) { data in
                        VStack {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: 30, height: CGFloat(data.factsRead * 10))
                                .cornerRadius(4)
                            
                            Text(data.day)
                                .font(.caption)
                                .foregroundColor(.mutedForeground)
                        }
                    }
                }
                .frame(height: 120)
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.muted.opacity(0.3))
        .cornerRadius(UI.corner)
        .padding(.horizontal)
    }
    
    private func statsCardsSection(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: UI.Spacing.medium) {
            StatCardView(
                title: "Streak",
                value: "\(viewStore.stats.streakDays)",
                icon: "🔥",
                valueColor: .orange
            )
            
            StatCardView(
                title: "Fakta lästa",
                value: "\(viewStore.stats.totalFactsRead)",
                icon: "📚",
                valueColor: .secondary
            )
            
            StatCardView(
                title: "Quiz-snitt",
                value: "\(viewStore.stats.avgQuizScore)%",
                icon: "🧠",
                valueColor: .accent
            )
            
            StatCardView(
                title: "Badges",
                value: "\(viewStore.stats.badgesUnlocked)",
                icon: "🏆",
                valueColor: .green
            )
        }
        .padding(.horizontal)
    }
    
    private func badgesSection(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            Text("Badges")
                .font(Typography.headline)
                .foregroundColor(.adaptiveForeground)
                .padding(.horizontal)
            
            BadgesGridView(badges: viewStore.badges)
                .padding(.horizontal)
        }
    }
    
    private func actionButtonsSection(viewStore: ViewStore<ProfileState, ProfileAction>) -> some View {
        VStack(spacing: UI.Spacing.medium) {
            HStack(spacing: UI.Spacing.medium) {
                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Inställningar")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                }
                
                Button(action: {
                    showingAbout = true
                }) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("Om")
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                }
            }
            
            Button(action: {
                showingLeaderboard = true
            }) {
                HStack {
                    Image(systemName: "trophy.fill")
                    Text("Topplista")
                }
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.muted)
                .cornerRadius(UI.corner)
            }
        }
        .padding(.horizontal)
    }
    
    private func calculateXP(from stats: UserStats) -> Int {
        return 10 * stats.totalFactsRead + 25 * stats.totalQuizzes + 5 * stats.streakDays + 50 * stats.badgesUnlocked
    }
    
    private func checkForCelebrations(viewStore: ViewStore<ProfileState, ProfileAction>) {
        // Check for level up
        if viewStore.stats.level > previousLevel {
            celebrationType = .levelUp
            previousLevel = viewStore.stats.level
        }
        
        // Check for new badges
        if viewStore.badges.count > previousBadgeCount {
            celebrationType = .badgeUnlocked
            previousBadgeCount = viewStore.badges.count
        }
    }
    
    // MARK: - Chart Data Generation
    private func generateWeeklyActivityData() -> [WeeklyActivityData] {
        let calendar = Calendar.current
        let today = Date()
        let daysOfWeek = ["Mån", "Tis", "Ons", "Tors", "Fre", "Lör", "Sön"]
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) ?? today
            let dayName = daysOfWeek[calendar.component(.weekday, from: date) - 1]
            
            // Simulate some activity data (in real app, this would come from actual data)
            let factsRead = Int.random(in: 0...10)
            
            return WeeklyActivityData(day: dayName, factsRead: factsRead)
        }.reversed()
    }
}

// MARK: - Chart Data Models
struct QuizChartData: Identifiable {
    let id = UUID()
    let index: Int
    let score: Double
    let date: Date
}

struct WeeklyActivityData: Identifiable {
    let id = UUID()
    let day: String
    let factsRead: Int
}

// MARK: - Level Progress View
struct LevelProgressView: View {
    let stats: UserStats
    @State private var showLevelUpAnimation = false
    @State private var progressAnimation = false
    @State private var xpPulse = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
            // Level Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.accent)
                        
                        Text("Nivå \(stats.calculatedLevel)")
                            .font(Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.adaptiveForeground)
                        
                        if stats.hasLeveledUp {
                            Text("🎉")
                                .font(.title2)
                                .scaleEffect(showLevelUpAnimation ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: showLevelUpAnimation)
                        }
                    }
                    
                    Text("Fakta-utforskare")
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(stats.calculatedXP) XP")
                        .font(Typography.headline)
                        .foregroundColor(.primary)
                        .scaleEffect(xpPulse ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: xpPulse)
                    
                    Text("\(stats.xpProgress)/100 till nästa")
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(stats.xpProgress) / 100 XP")
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                    
                    Spacer()
                    
                    let progress = Double(stats.xpProgress) / 100.0
                    Text("\(Int(progress * 100))%")
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                }
                
                ProgressView(value: Double(stats.xpProgress), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accent))
                    .scaleEffect(y: 1.5)
                    .scaleEffect(x: progressAnimation ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: progressAnimation)
            }
        }
        .onAppear {
            showLevelUpAnimation = stats.hasLeveledUp
            progressAnimation = true
            xpPulse = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                xpPulse = false
            }
        }
        .onChange(of: stats.calculatedXP) { oldXP, newXP in
            if newXP > oldXP {
                xpPulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    xpPulse = false
                }
            }
        }
    }
}

// MARK: - Streak Display View
struct StreakDisplayView: View {
    let streakDays: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text("\(streakDays) dagar i rad")
                .font(Typography.caption)
                .foregroundColor(.mutedForeground)
        }
    }
}

// MARK: - Stat Card View
struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let valueColor: Color
    
    var body: some View {
        VStack(spacing: UI.Spacing.small) {
            Text(icon)
                .font(.title2)
            
            Text(value)
                .font(Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
            
            Text(title)
                .font(Typography.caption)
                .foregroundColor(.mutedForeground)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.muted.opacity(0.3))
        .cornerRadius(UI.corner)
    }
}

// MARK: - Badges Grid View
struct BadgesGridView: View {
    let badges: [Badge]
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: UI.Spacing.medium) {
            ForEach(badges) { badge in
                BadgeView(badge: badge)
            }
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: UI.Spacing.small) {
            Text(badge.icon)
                .font(.title)
                .opacity(badge.isUnlocked ? 1.0 : 0.3)
            
            Text(badge.name)
                .font(Typography.caption)
                .foregroundColor(badge.isUnlocked ? .primary : .mutedForeground)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: UI.corner)
                .fill(badge.isUnlocked ? badge.color.opacity(0.2) : Color.muted.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: UI.corner)
                .stroke(badge.isUnlocked ? badge.color : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let avatarData: AvatarData
    let displayName: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
            
            if let emoji = avatarData.emoji {
                Text(emoji)
                    .font(.title)
            } else {
                Text(String(displayName.prefix(1)).uppercased())
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: UI.Spacing.large) {
                Text("Om Facta")
                    .font(Typography.largeTitle)
                    .fontWeight(.bold)
                
                Text("En app för att lära sig fascinerande fakta om världen omkring oss.")
                    .font(Typography.body)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}