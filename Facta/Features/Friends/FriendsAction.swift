import Foundation

enum FriendsAction: Equatable {
    case load
    case addFriend(String)
    case acceptRequest(UUID)
    case declineRequest(UUID)
    case removeFriend(UUID)
    case challengeFriend(UUID)
    case matchCompleted(Match)
}
