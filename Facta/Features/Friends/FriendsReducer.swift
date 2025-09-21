import Foundation
import ComposableArchitecture

struct FriendsReducer: Reducer {
    typealias State = FriendsState
    typealias Action = FriendsAction
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .load:
                state.isLoading = true
                // Simulate loading friends
                state.friends = generateSampleFriends()
                state.pendingRequests = generateSamplePendingRequests()
                state.sentRequests = generateSampleSentRequests()
                state.isLoading = false
                return .none
                
            case .addFriend(let name):
                // Add friend logic
                return .none
                
            case .acceptRequest(let id):
                if let request = state.pendingRequests.first(where: { $0.id == id }) {
                    state.pendingRequests.removeAll { $0.id == id }
                    state.friends.append(request)
                }
                return .none
                
            case .declineRequest(let id):
                state.pendingRequests.removeAll { $0.id == id }
                return .none
                
            case .removeFriend(let id):
                state.friends.removeAll { $0.id == id }
                return .none
                
            case .challengeFriend(let id):
                // Challenge friend logic
                return .none
                
            case .matchCompleted(let match):
                // Handle match completion
                return .none
            }
        }
    }
    
    private func generateSampleFriends() -> [Friend] {
        return [
            Friend(name: "Anna", avatar: "👩", level: 5, isOnline: true),
            Friend(name: "Erik", avatar: "👨", level: 3, isOnline: false),
            Friend(name: "Maria", avatar: "👩‍🦱", level: 7, isOnline: true)
        ]
    }
    
    private func generateSamplePendingRequests() -> [Friend] {
        return [
            Friend(name: "Lars", avatar: "👨‍🦳", level: 4, isOnline: false)
        ]
    }
    
    private func generateSampleSentRequests() -> [Friend] {
        return [
            Friend(name: "Sofia", avatar: "👩‍🦰", level: 6, isOnline: true)
        ]
    }
}
