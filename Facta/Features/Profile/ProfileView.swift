import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    let store: StoreOf<ProfileReducer>
    @State private var showingSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: UI.Spacing.large) {
                    // Header
                    VStack(spacing: UI.Spacing.medium) {
                        // Avatar
                        Circle()
                            .fill(LinearGradient(colors: [.primary, .secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("G")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        // Name and Streak
                        VStack(spacing: UI.Spacing.small) {
                            Text("Gäst")
                                .font(Typography.title2)
                                .foregroundColor(.primary)
                            
                            HStack {
                                Text("🔥")
                                Text("\(viewStore.stats.streakDays) dagars streak")
                                    .font(Typography.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    
                    // XP/Progress
                    VStack(alignment: .leading, spacing: UI.Spacing.small) {
                        HStack {
                            Text("XP")
                                .font(Typography.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(calculateXP(from: viewStore.stats))")
                                .font(Typography.headline)
                                .foregroundColor(.primary)
                        }
                        
                        ProgressView(value: Double(viewStore.stats.avgQuizScore), total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: .primary))
                    }
                    .padding()
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                    .padding(.horizontal)
                    
                    // Stats Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: UI.Spacing.medium) {
                        StatCardView(
                            title: "Streak",
                            value: "\(viewStore.stats.streakDays)",
                            icon: "🔥"
                        )
                        
                        StatCardView(
                            title: "Fakta lästa",
                            value: "\(viewStore.stats.totalFactsRead)",
                            icon: "📚"
                        )
                        
                        StatCardView(
                            title: "Quiz-snitt",
                            value: "\(viewStore.stats.avgQuizScore)%",
                            icon: "🧠"
                        )
                        
                        StatCardView(
                            title: "Badges",
                            value: "\(viewStore.stats.badgesUnlocked)",
                            icon: "🏆"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Badges Section
                    VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                        HStack {
                            Text("Badges")
                                .font(Typography.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(viewStore.stats.badgesUnlocked)/\(viewStore.badges.count)")
                                .font(Typography.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        BadgesGridView(badges: viewStore.badges)
                        
                        // Next Badge
                        if let nextBadge = viewStore.badges.first(where: { !$0.isUnlocked }) {
                            VStack(alignment: .leading, spacing: UI.Spacing.small) {
                                Text("Nästa badge:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(nextBadge.icon) \(nextBadge.name)")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                
                                Text(nextBadge.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.muted)
                            .cornerRadius(UI.corner)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Settings and About Buttons
                    VStack(spacing: UI.Spacing.medium) {
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
                                Text("Om Facta")
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
                .padding(.vertical)
            }
            .onAppear {
                viewStore.send(.load)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(store: store)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private func calculateXP(from stats: UserStats) -> Int {
        return 10 * stats.totalFactsRead + 25 * stats.totalQuizzes + 5 * stats.streakDays + 50 * stats.badgesUnlocked
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    
    private var iconColor: Color {
        switch title {
        case "Streak":
            return .orange
        case "Fakta lästa":
            return .secondary
        case "Quiz-snitt":
            return .accent
        case "Badges":
            return .green
        default:
            return .primary
        }
    }
    
    private var systemIcon: String {
        switch title {
        case "Streak":
            return "flame.fill"
        case "Fakta lästa":
            return "book.fill"
        case "Quiz-snitt":
            return "brain.head.profile"
        case "Badges":
            return "trophy.fill"
        default:
            return "star.fill"
        }
    }
    
    var body: some View {
        VStack(spacing: UI.Spacing.small) {
            Image(systemName: systemIcon)
                .font(.title2)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(Typography.headline)
                .foregroundColor(.primary)
            
            Text(title)
                .font(Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.muted)
        .cornerRadius(UI.corner)
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: UI.Spacing.large) {
                Text("Om Facta")
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                
                Text("En app för att lära sig fascinerande fakta och testa sina kunskaper med quiz.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Stäng") {
                        dismiss()
                    }
                }
            }
        }
    }
}
