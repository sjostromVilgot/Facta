import SwiftUI
import ComposableArchitecture

struct ChallengesView: View {
    let store: Store<ChallengesState, ChallengesAction>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: UI.Spacing.large) {
                        // Daily Challenges
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            Text("Dagliga utmaningar")
                                .font(Typography.headline)
                                .foregroundColor(.adaptiveForeground)
                            
                            ForEach(viewStore.dailyChallenges) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    viewStore.send(.markComplete(challenge.id))
                                }
                            }
                        }
                        .padding()
                        .background(Color.muted.opacity(0.3))
                        .cornerRadius(UI.corner)
                        .padding(.horizontal)
                        
                        // Weekly Challenges
                        VStack(alignment: .leading, spacing: UI.Spacing.medium) {
                            Text("Veckovisa utmaningar")
                                .font(Typography.headline)
                                .foregroundColor(.adaptiveForeground)
                            
                            ForEach(viewStore.weeklyChallenges) { challenge in
                                ChallengeCardView(challenge: challenge) {
                                    viewStore.send(.markComplete(challenge.id))
                                }
                            }
                        }
                        .padding()
                        .background(Color.muted.opacity(0.3))
                        .cornerRadius(UI.corner)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Utmaningar")
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
}

struct ChallengeCardView: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: UI.Spacing.small) {
                Text(challenge.description)
                    .font(Typography.body)
                    .foregroundColor(.adaptiveForeground)
                
                HStack {
                    Text("\(challenge.progress)/\(challenge.target)")
                        .font(Typography.caption)
                        .foregroundColor(.mutedForeground)
                    
                    Spacer()
                    
                    Text("\(challenge.reward) XP")
                        .font(Typography.caption)
                        .foregroundColor(.accent)
                }
                
                ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                    .progressViewStyle(LinearProgressViewStyle(tint: .accent))
            }
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else if challenge.progress >= challenge.target {
                Button("Slutför") {
                    onComplete()
                }
                .font(Typography.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accent)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.muted.opacity(0.2))
        .cornerRadius(UI.corner)
    }
}