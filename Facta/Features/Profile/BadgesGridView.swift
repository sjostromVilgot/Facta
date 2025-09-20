import SwiftUI
import ComposableArchitecture

struct BadgesGridView: View {
    let badges: [Badge]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: UI.Spacing.small) {
            ForEach(badges, id: \.id) { badge in
                BadgeView(badge: badge)
            }
        }
    }
}

struct BadgeView: View {
    let badge: Badge
    
    var body: some View {
        VStack(spacing: UI.Spacing.small) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? Color.primary.opacity(0.1) : Color.muted)
                    .frame(width: 50, height: 50)
                
                if badge.isUnlocked {
                    Text(badge.icon)
                        .font(.title2)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(badge.name)
                .font(.caption)
                .foregroundColor(badge.isUnlocked ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, UI.Padding.small)
    }
}
