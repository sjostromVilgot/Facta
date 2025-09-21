import SwiftUI
import ComposableArchitecture

struct LeaderboardView: View {
    let store: StoreOf<LeaderboardReducer>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 0) {
                    if viewStore.isLoading {
                        Spacer()
                        ProgressView("Laddar topplista...")
                            .font(Typography.body)
                        Spacer()
                    } else if viewStore.errorMessage != nil {
                        Spacer()
                        VStack(spacing: UI.Spacing.medium) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Kunde inte ladda topplista")
                                .font(Typography.headline)
                                .foregroundColor(.primary)
                            
                            Text(viewStore.errorMessage ?? "Okänt fel")
                                .font(Typography.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Försök igen") {
                                viewStore.send(.loadLeaderboard)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        Spacer()
                    } else {
                        // Leaderboard Content
                        VStack(spacing: 0) {
                            // Header with current selection
                            VStack(spacing: UI.Spacing.small) {
                                Text(viewStore.selectedLeaderboard.displayName)
                                    .font(Typography.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(viewStore.selectedLeaderboard.description)
                                    .font(Typography.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color.muted)
                            
                            // Leaderboard Picker
                            Picker("Leaderboard", selection: viewStore.binding(
                                get: \.selectedLeaderboard,
                                send: LeaderboardAction.selectLeaderboard
                            )) {
                                ForEach(LeaderboardIdentifier.allCases, id: \.self) { leaderboard in
                                    Text(leaderboard.displayName).tag(leaderboard)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding()
                            
                            // Leaderboard List
                            if viewStore.leaderboardData.entries.isEmpty {
                                Spacer()
                                VStack(spacing: UI.Spacing.medium) {
                                    Image(systemName: "trophy")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    
                                    Text("Inga resultat än")
                                        .font(Typography.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Börja spela för att se ditt resultat här!")
                                        .font(Typography.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                Spacer()
                            } else {
                                List {
                                    ForEach(viewStore.leaderboardData.entries) { entry in
                                        LeaderboardEntryView(entry: entry)
                                    }
                                }
                                .listStyle(PlainListStyle())
                            }
                        }
                    }
                }
                .navigationTitle("Topplista")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Stäng") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    viewStore.send(.loadLeaderboard)
                }
            }
        }
    }
}

// MARK: - Leaderboard Entry View
struct LeaderboardEntryView: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: UI.Spacing.medium) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(entry.rank)")
                    .font(Typography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.playerName)
                        .font(Typography.headline)
                        .foregroundColor(entry.isLocalPlayer ? .primary : .adaptiveForeground)
                        .fontWeight(entry.isLocalPlayer ? .bold : .regular)
                    
                    if entry.isLocalPlayer {
                        Text("(Du)")
                            .font(Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("\(entry.score) poäng")
                    .font(Typography.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Trophy icon for top 3
            if entry.rank <= 3 {
                Image(systemName: trophyIcon)
                    .font(.title2)
                    .foregroundColor(trophyColor)
            }
        }
        .padding(.vertical, UI.Padding.small)
        .background(entry.isLocalPlayer ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(UI.corner)
    }
    
    private var rankColor: Color {
        switch entry.rank {
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3:
            return .orange
        default:
            return .blue
        }
    }
    
    private var trophyIcon: String {
        switch entry.rank {
        case 1:
            return "crown.fill"
        case 2:
            return "medal.fill"
        case 3:
            return "medal.fill"
        default:
            return "trophy.fill"
        }
    }
    
    private var trophyColor: Color {
        switch entry.rank {
        case 1:
            return .yellow
        case 2:
            return .gray
        case 3:
            return .orange
        default:
            return .blue
        }
    }
}

// MARK: - Leaderboard Reducer
struct LeaderboardState: Equatable {
    var selectedLeaderboard: LeaderboardIdentifier = .totalXP
    var leaderboardData: LeaderboardData = LeaderboardData(entries: [], localPlayerRank: nil, localPlayerScore: nil)
    var isLoading: Bool = false
    var errorMessage: String?
}

enum LeaderboardAction: Equatable {
    case loadLeaderboard
    case selectLeaderboard(LeaderboardIdentifier)
    case leaderboardLoaded(LeaderboardData)
    case leaderboardError(String)
}

struct LeaderboardReducer: Reducer {
    typealias State = LeaderboardState
    typealias Action = LeaderboardAction
    
    @Dependency(\.gameCenterClient) var gameCenterClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadLeaderboard:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [leaderboardID = state.selectedLeaderboard.rawValue] send in
                    do {
                        let data = try await gameCenterClient.loadLeaderboard(leaderboardID)
                        await send(.leaderboardLoaded(data))
                    } catch {
                        await send(.leaderboardError(error.localizedDescription))
                    }
                }
                
            case .selectLeaderboard(let leaderboard):
                state.selectedLeaderboard = leaderboard
                return .send(.loadLeaderboard)
                
            case .leaderboardLoaded(let data):
                state.leaderboardData = data
                state.isLoading = false
                state.errorMessage = nil
                return .none
                
            case .leaderboardError(let message):
                state.errorMessage = message
                state.isLoading = false
                return .none
            }
        }
    }
}
