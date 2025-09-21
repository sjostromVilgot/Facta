import SwiftUI
import ComposableArchitecture

struct FriendsView: View {
    let store: Store<FriendsState, FriendsAction>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            NavigationView {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "person.2.fill")
                                .font(Typography.largeTitle)
                                .foregroundColor(.primary)
                            
                            Text(NSLocalizedString("Vänner", comment: "Friends title"))
                                .font(Typography.largeTitle)
                                .foregroundColor(.adaptiveForeground)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewStore.send(.setShowingAddFriend(true))
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, UI.Padding.large)
                    .padding(.top, 8)
                    
                    // Friends List
                    if viewStore.friends.isEmpty {
                        emptyStateView
                    } else {
                        friendsListView(viewStore: viewStore)
                    }
                }
                .navigationBarHidden(true)
                .sheet(isPresented: viewStore.binding(
                    get: \.showingAddFriend,
                    send: FriendsAction.setShowingAddFriend
                )) {
                    addFriendSheet(viewStore: viewStore)
                }
                .onAppear {
                    viewStore.send(.load)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.mutedForeground)
            
            Text(NSLocalizedString("Inga vänner än", comment: "No friends yet"))
                .font(Typography.headline)
                .foregroundColor(.adaptiveForeground)
            
            Text(NSLocalizedString("Lägg till vänner för att utmana dem i quiz!", comment: "Add friends to challenge them in quizzes"))
                .font(Typography.body)
                .foregroundColor(.mutedForeground)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                // This will be handled by the parent viewStore
            }) {
                Text(NSLocalizedString("Lägg till vän", comment: "Add friend"))
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primary)
                    .cornerRadius(UI.corner)
            }
            
            Spacer()
        }
    }
    
    private func friendsListView(viewStore: ViewStore<FriendsState, FriendsAction>) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewStore.friends) { friend in
                    FriendCardView(
                        friend: friend,
                        onChallenge: {
                            viewStore.send(.challengeFriend(friend.id))
                            // Navigate to quiz with friend context
                            viewStore.send(.startQuizWithFriend(friend.id))
                        },
                        onRemove: {
                            viewStore.send(.removeFriend(friend.id))
                        }
                    )
                }
            }
            .padding(.horizontal, UI.Padding.large)
            .padding(.top, 20)
        }
    }
    
    private func addFriendSheet(viewStore: ViewStore<FriendsState, FriendsAction>) -> some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(NSLocalizedString("Lägg till vän", comment: "Add friend"))
                    .font(Typography.largeTitle)
                    .foregroundColor(.adaptiveForeground)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("Namn", comment: "Name"))
                        .font(Typography.headline)
                        .foregroundColor(.adaptiveForeground)
                    
                    TextField(
                        NSLocalizedString("Ange vännens namn", comment: "Enter friend's name"),
                        text: viewStore.binding(
                            get: \.newFriendName,
                            send: FriendsAction.setNewFriendName
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Typography.body)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(NSLocalizedString("Avbryt", comment: "Cancel")) {
                        viewStore.send(.setShowingAddFriend(false))
                    }
                    .font(Typography.button)
                    .foregroundColor(.mutedForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.muted)
                    .cornerRadius(UI.corner)
                    
                    Button(NSLocalizedString("Lägg till", comment: "Add")) {
                        if !viewStore.newFriendName.isEmpty {
                            viewStore.send(.addFriend(viewStore.newFriendName))
                        }
                    }
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(viewStore.newFriendName.isEmpty ? Color.muted : Color.primary)
                    .cornerRadius(UI.corner)
                    .disabled(viewStore.newFriendName.isEmpty)
                }
                .padding(.horizontal, UI.Padding.large)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

struct FriendCardView: View {
    let friend: Friend
    let onChallenge: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.primary.opacity(0.1), .secondary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(friend.avatar)
                    .font(.title2)
            }
            
            // Friend Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(friend.name)
                        .font(Typography.headline)
                        .foregroundColor(.adaptiveForeground)
                    
                    if friend.isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.caption)
                            .foregroundColor(.mutedForeground)
                        Text("\(friend.totalFactsRead)")
                            .font(Typography.caption)
                            .foregroundColor(.mutedForeground)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(friend.bestStreak)")
                            .font(Typography.caption)
                            .foregroundColor(.mutedForeground)
                    }
                }
            }
            
            Spacer()
            
            // Challenge Button
            Button(action: onChallenge) {
                Text(NSLocalizedString("Utmana", comment: "Challenge"))
                    .font(Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primary)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.muted.opacity(0.3))
        .cornerRadius(UI.corner)
        .contextMenu {
            Button(NSLocalizedString("Ta bort vän", comment: "Remove friend"), role: .destructive) {
                onRemove()
            }
        }
    }
}

#Preview {
    FriendsView(
        store: Store(initialState: FriendsState()) {
            FriendsReducer()
        }
    )
}
